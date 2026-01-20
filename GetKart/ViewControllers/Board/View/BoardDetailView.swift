//
//  BoardDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//

import SwiftUI
import Kingfisher

struct BoardDetailView: View{
    
    @State private var currentIndex: Int = 0
    var navigationController:UINavigationController?
    @State private var listArray:Array<ItemModel> = [ItemModel]()
    @State private var page = 1
    @State private var isDataLoading = true
    let itemObj:ItemModel

    var body: some View {
        
        VStack(spacing: 0) {
            
            // HEADER
            HStack {
                Button {
                    navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }.frame(width: 40, height: 40)
                
                Text(itemObj.category?.name ?? "").font(Font.inter(.semiBold, size: 16)).foregroundColor(Color(UIColor.label))
                Spacer()
                
                if listArray.count > 0{
                    if (listArray[currentIndex].user?.id ?? 0) != Local.shared.getUserId(){
                        Button {
                            openActionSheetToReportBoard(boardIndex: currentIndex)
                        } label: {
                            Image("more")
                                .renderingMode(.template)
                                .foregroundColor(Color(UIColor.label))
                        }
                        .frame(width: 40, height: 40)
                    }
                }
            }
            .padding(.horizontal,5)
            .frame(height: 44)
            .background(Color(.systemBackground))
            .zIndex(1)
            
            
            if !listArray.isEmpty {
                
                VerticalPager(
                    pages: listArray.map { ReelPostView(post: $0,
                                                        sendLikeDislikeObject: { isLiked, boardId,likeCount  in
                        
                        if let index = listArray.firstIndex(where: { $0.id == boardId }) {
                            // index is Int
                            print("Found at index:", index)
                            var obj = listArray[index]
                            obj.isLiked = isLiked
                            obj.totalLikes = likeCount
                            listArray[index] = obj
                        }
                    }) }
                    ,
                    onPageChange: { index in
                        currentIndex = index
                        print("====\(currentIndex)")
                        boardClickApi(post: listArray[index])
                        
                    })
                .padding(5)
                .onChange(of:currentIndex) { newIndex in
                    if newIndex == listArray.count - 1 {
                        getBoardListApi()
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            
            if listArray.count == 0{
                getBoardListApi()
                boardClickApi(post: itemObj)
            }
        }
        
        .background(
            
            NavigationConfigurator { nav in
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = nil
            }
        ) //Added for swipe pop navigation
        
        .background(Color(.systemGray6))
        
    }

    
    //MARK: Api methods
    func boardClickApi(post:ItemModel){
        
       
        let params = ["board_id":post.id ?? 0]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.board_click, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                }else{
                }
            }
        }
    }
    func getBoardListApi(){
        
        if self.page == 1{
            self.listArray.removeAll()
            self.listArray.append(itemObj)
        }
        let strUrl = Constant.shared.get_related_boards + "?page=\(page)&category_id=\(itemObj.categoryID ?? 0)&exclude_id=\(itemObj.id ?? 0)"

 
        self.isDataLoading = true
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl,loaderPos: .mid) { (obj:ItemParse) in
            
            if obj.code == 200 {
             
                DispatchQueue.main.async {
                    let newItems = obj.data?.data ?? []
                    guard !newItems.isEmpty else {
                        self.isDataLoading = false
                        
                        return }

                    self.listArray.append(contentsOf: newItems)
                    self.page += 1
                    self.isDataLoading = false
                }
                

            }else{
                self.isDataLoading = false
            }
        }
    }
    
    
    
    func openActionSheetToReportBoard(boardIndex:Int){
        
        if listArray[boardIndex].isAlreadyReported == true{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Already reported.")
        }else{
            let sheet = UIAlertController(
                title: "",
                message: nil,
                preferredStyle: .actionSheet
            )
            
            let strText = "Report Board"
            sheet.addAction(UIAlertAction(title: strText, style: .default, handler: { action in
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    let reportAds =  ReportAdsView(itemId:(listArray[boardIndex].id ?? 0),isToReportBoard:true) {bool in
                        listArray[boardIndex].isAlreadyReported = bool
                    }
                    let destVC = UIHostingController(rootView:reportAds)
                    destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
                    destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
                    destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                    self.navigationController?.present(destVC, animated: true, completion: nil)
                }
            }))
            
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            UIApplication.shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?
                .rootViewController?
                .present(sheet, animated: true)
        }
    }
}

struct ReelPostView: View {
    @State var post: ItemModel
    @State private var showShareSheet = false
    var sendLikeDislikeObject: (_ isLiked:Bool, _ boardId:Int, _ likeCount:Int) -> Void

    @State private var showSeeMore = false
    @State private var isTextTruncated = false
    @State private var showSafari = false

    
    var body: some View {

        VStack(spacing: 0) {

            // IMAGE + CARD BEHIND IT
            ZStack {

                // 🔹 CARD BEHIND IMAGE
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color(.label).opacity(0.18),
                        radius: 7,
                        x: 0,
                        y: 5
                    )

                // 🔹 IMAGE
                if let url = URL(string: post.image ?? "") {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                       // .padding(12) // 👈 spacing from card edges
                }
            }

            // 🔹 FLAT CONTENT (NO CARD)
            bottomCard
                .padding(.horizontal)
                .padding(.top, 10)

            // 🔹 BUY NOW
            Button {
                showSafari = true
                outboundClickApi(strURl: post.outbondUrl ?? "")
            } label: {
                Text("Buy Now")
                    .font(.inter(.semiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 55)
            }
            .background(Color(hexString: "#FF9900"))
            .cornerRadius(10)
            .padding()
        }.background(Color(.systemBackground))
        
            .sheet(isPresented: $showSeeMore) {
                DynamicHeightSheet(
                    content: SeeMorePopupView(
                        title: post.name ?? "",
                        description: post.description ?? ""
                    ) {
                        showSeeMore = false
                        showSafari = true
                        outboundClickApi(strURl: post.outbondUrl ?? "")
                    }
                )
            }

            .fullScreenCover(isPresented: $showSafari) {
              
                if let url = URL(string:getUrlValid(strURl: post.outbondUrl ?? ""))  {
                    
                    SafariView(url:url)
                }
            }

    }

    func getUrlValid(strURl:String) ->String{
        var urlString = strURl
        if !urlString.lowercased().hasPrefix("http://") &&
              !urlString.lowercased().hasPrefix("https://") {
               urlString = "https://" + urlString
           }
        return urlString
    }
    
    private var imageHeight: CGFloat {
        UIScreen.main.bounds.height * 0.45
    }


    private var bottomCard: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack{
                HStack(spacing:3){
                    Button {
                        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                            post.isLiked?.toggle()
                            manageLikeDislikeApi()
                        }
                    } label: {
                        let imgStr = (post.isLiked == true) ? "like_fill" : "like"
                        Image(imgStr).foregroundColor(Color(.label))
                    }
                    if (post.totalLikes ?? 0) > 0{
                        
                        Text("\(post.totalLikes ?? 0)").font(Font.inter(.regular, size: 14)).foregroundColor(Color(.label))
                    }
                }
                
                Button {
                    showShareSheet = true
                } label: {
                    Image("Share-outline")//.renderingMode(.template).foregroundColor(Color(hex: "#818181"))
                }
                .actionSheet(isPresented: $showShareSheet) {
                    ActionSheet(
                        title: Text(""),
                        message: nil,
                        buttons: [
                            .default(Text("Copy Link"), action: {
                                UIPasteboard.general.string = ShareMedia.boardUrl + "\(post.id ?? 0)"
                                AlertView.sharedManager.showToast(message: "Copied successfully.")
                            }),
                            .default(Text("Share"), action: {
                                
                                ShareMedia.shareMediafrom(type: .board, mediaId: "\(post.id ?? 0)", controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                            }),
                            .cancel()
                        ]
                    )
                }
                
                Spacer()
                if (post.isFeature ?? false){
                    Text("Sponsered").font(.inter(.medium, size: 16)).foregroundColor(Color(.gray))
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(post.name ?? "")
                    .font(.inter(.medium, size: 18))
                    .foregroundColor(Color(.label))
                //Text(post.description ?? "") .font(.inter(.regular, size: 14))
                
                ZStack(alignment: .bottomTrailing) {
                    
                    TruncatableText(
                        text: post.description ?? "",
                        lineLimit: 2,
                        font: .inter(.regular, size: 14)
                    ) { truncated in
                        isTextTruncated = truncated
                    }.padding(.trailing, isTextTruncated ? 65 : 0) // 👈 space for "See more"
                    
                    if isTextTruncated {
                        Button {
                            showSeeMore = true
                        } label: {
                            Text("See more")
                                .font(.inter(.bold, size: 14))
                                .foregroundColor(Color(.label))
                        }
                    }
                }
                
                if (post.specialPrice ?? 0.0) > 0{
                    HStack{
                        Text("\(Local.shared.currencySymbol)\((post.specialPrice ?? 0.0).formatNumber())")
                            .font(.inter(.medium, size: 18))
                            .foregroundColor(Color(hex: "#008838"))
                        Text("\(Local.shared.currencySymbol)\((post.price ?? 0.0).formatNumber())")
                            .font(.inter(.medium, size: 15))
                            .foregroundColor(Color(.gray)).strikethrough(true, color: .secondary)
                        let per = (((post.price ?? 0.0) - (post.specialPrice ?? 0.0)) / (post.price ?? 0.0)) * 100.0
                        Text("\(per.formatNumber())% Off").font(.inter(.medium, size: 12))
                            .foregroundColor(Color(hex: "#008838"))
                        
                    }.padding(.top,5)

                }else{
                   
                    Text("\(Local.shared.currencySymbol) \((post.price ?? 0.0).formatNumber())")
                        .font(.inter(.medium, size: 18))
                        .foregroundColor(Color(hex: "#008838")).padding(.top,5)
                }
            }
            
//            Button {
//                outboundClickApi(strURl: post.outbondUrl ?? "")
//            } label: {
//                
//                Text("Buy Now").font(.inter(.semiBold, size: 16.0)).foregroundColor(.white).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
//                  
//            }.background(Color(hexString: "#FF9900"))
//             .cornerRadius(8).padding([.bottom,.top])
        }

    }
    
    
    
    func outboundClickApi(strURl:String){
        
        let params = ["board_id":post.id ?? 0]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.board_outbond_click, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{

                }else{
                }
            }
        }
        
      /*   var urlString = strURl
         if !urlString.lowercased().hasPrefix("http://") &&
               !urlString.lowercased().hasPrefix("https://") {
                urlString = "https://" + urlString
            }
        if let url = URL(string: urlString)  {
            print(urlString)
            let vc = UIHostingController(rootView:  PreviewURL(fileURLString:urlString,isCopyUrl:true))
            AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
            
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                print("Cannot open URL")
//            }
        }*/
      
    }
    

    
    
    func manageLikeDislikeApi(){
        
        let params = ["board_id":post.id ?? 0]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_board_favourite, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    if let  data = result["data"] as? Dictionary<String,Any>{
                     
                        if let favouriteCount = data["favourite_count"] as? Int{
                            
                            post.totalLikes = favouriteCount
                          
                            self.sendLikeDislikeObject(post.isLiked ?? false, post.id ?? 0, favouriteCount)
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshLikeDislikeBoard.rawValue), object:  ["isLike":post.isLiked ?? false,"count":favouriteCount,"boardId":self.post.id ?? 0], userInfo: nil)


                        }
                    }
                    
                }else{
                    
                }
            }
        }
    }
}

struct VerticalPager<Content: View>: UIViewControllerRepresentable {

    var pages: [Content]
    var onPageChange: ((Int) -> Void)?   // 👈 callback

    func makeUIViewController(context: Context) -> PagerVC {
        let vc = PagerVC()
        vc.onPageChange = onPageChange
        vc.setPages(pages)
        //vc.pages = pages.map { UIHostingController(rootView: $0) }
        return vc
    }

    func updateUIViewController(_ uiViewController: PagerVC, context: Context) {
        
        uiViewController.setPages(pages)
    }
}

class PagerVC: UIViewController, UIScrollViewDelegate {

    private(set) var pages: [UIViewController] = []
    let scrollView = UIScrollView()

    private var lastIndex = 0
    var onPageChange: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true   // 🔥 IMPORTANT
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPages()
    }

    // 🔥 APPEND-SAFE PAGE UPDATE
    func setPages(_ newPages: [some View]) {
        guard newPages.count >= pages.count else { return }

        let oldCount = pages.count
        let currentOffset = scrollView.contentOffset

        for index in oldCount..<newPages.count {
            let vc = UIHostingController(rootView: newPages[index])
            addChild(vc)
            vc.view.backgroundColor = .systemBackground
            scrollView.addSubview(vc.view)
            vc.didMove(toParent: self)
            pages.append(vc)
        }

        layoutPages()
        scrollView.contentOffset = currentOffset   // 🔒 preserve position
    }

    private func layoutPages() {
        scrollView.frame = view.bounds

        let pageHeight = view.bounds.height
        let pageWidth = view.bounds.width

        scrollView.contentSize = CGSize(
            width: pageWidth,
            height: pageHeight * CGFloat(pages.count)
        )

        for (i, vc) in pages.enumerated() {
            vc.view.frame = CGRect(
                x: 0,
                y: pageHeight * CGFloat(i),
                width: pageWidth,
                height: pageHeight
            )
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.y / view.bounds.height))
        if index != lastIndex {
            lastIndex = index
            onPageChange?(index)
        }
    }
}



struct PostImagesCarousel: View {
    let images: [String]

    var body: some View {
        TabView {
            ForEach(images, id: \.self) { img in
                
                if let url = URL(string: img){
                    
                    
                    AsyncImage(url: url) { img in
                        img.resizable()
                            .resizable()
                            .scaledToFit()
                         .frame(maxWidth: UIScreen.ft_width())
                            .clipped()
                    } placeholder: {
                        Image("getkartplaceholder")
                            .resizable()
                            .scaledToFit()
                            .clipped()
                    }
                }

            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(maxHeight: 400) // match your UI
        .clipped()
    }
}



struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                configure(nav)
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}



import UIKit
import CoreImage

extension UIImage {

    func averageColorNew() -> UIColor? {
        guard let ciImage = CIImage(image: self) else { return nil }

        let extent = ciImage.extent
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: ciImage,
                kCIInputExtentKey: CIVector(
                    x: extent.origin.x,
                    y: extent.origin.y,
                    z: extent.size.width,
                    w: extent.size.height
                )
            ]
        )

        guard let outputImage = filter?.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1
        )
    }
}



/*  var body: some View {

      VStack(spacing: 0) {

          // IMAGE
          GeometryReader { geo in
            //  ZStack(alignment:.top){
              ZStack(alignment: .top) {
                  // avgColor   // 🔥 background from image

               /*   AsyncImage(url: URL(string: post.image ?? "")) { img in
                      img
                          .resizable()
                      
                      
                          .scaledToFit()
                          //.frame(width: geo.size.width, height: geo.size.height)
                          .frame(maxWidth: .infinity)
                      // .clipped()
//                            .cornerRadius(10)
//                            .shadow(
//                                color: Color.black.opacity(0.10),
//                                radius: 7,
//                                x: 0,
//                                y: 2
//                            )
                          . padding(0)
                          .onAppear {
                             // extractAverageColor(from: img)
                          }
                  } placeholder: {
                      Color.black
                  }*/
                  
                  if let url = URL(string: post.image ?? "") {
                      
                      
                     // GeometryReader { geo in
                          KFImage(url)
                              .resizable()
                             // .scaledToFill()
                              //.frame(width: geo.size.width,height:imgHeight)
                              //.aspectRatio(3/4, contentMode: .fill)
                              .onSuccess { result in
                                              let size = result.image.size
                                              if size.height > 0 {
                                                  imageRatio = size.width / size.height
                                              }
                                          }
                                          .scaledToFill()
                                          .aspectRatio(imageRatio, contentMode: .fit)
                              .clipped()
//                                .cornerRadius(8)
//                                .shadow(
//                                    color: Color.black.opacity(0.10),
//                                    radius: 7,
//                                    x: 0,
//                                    y: 2
//                                )
  //                    }
  //                    .frame(height: imgHeight)
                  }

              }.background(Color(.systemBackground))
//                   .frame(width: geo.size.width, height: geo.size.height)
                  .frame(maxWidth: .infinity)
                  .frame(height: min(geo.size.height, UIScreen.main.bounds.height * 0.6))

              .cornerRadius(15)
                  .shadow(
                      color: Color.black.opacity(0.6),
                      radius: 15,
                      x: 0,
                      y: 6
                  )
          }
          //.cornerRadius(10)

          // BOTTOM CARD (ALWAYS VISIBLE)
          bottomCard.padding()
        //  Spacer()
          Button {
              outboundClickApi(strURl: post.outbondUrl ?? "")
          } label: {
              
              Text("Buy Now").font(.inter(.semiBold, size: 16.0)).foregroundColor(.white).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                
          }.background(Color(hexString: "#FF9900"))
              .cornerRadius(8).padding([.bottom,.top]).padding(.horizontal)
          
      }
          .background(Color(.systemBackground))
          //.cornerRadius(10)
          .clipped()
          //.padding(0)
  }
*/
  
//    private func extractAverageColor(from image: Image) {
//            let renderer = ImageRenderer(content: image)
//            renderer.scale = UIScreen.main.scale
//
//            if let uiImage = renderer.uiImage,
//               let color = uiImage.averageColor {
//                avgColor = Color(color)
//            }
//        }



/*
class PagerVC: UIViewController, UIScrollViewDelegate {

    var pages: [UIViewController] = []
    let scrollView = UIScrollView()

    private let pageSpacing: CGFloat = 0
    
    
      var onPageChange: ((Int) -> Void)?
      private var lastIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.isOpaque = false
        scrollView.delegate = self
        scrollView.bounces = false

        view.addSubview(scrollView)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let pageHeight = view.frame.height
        let pageWidth = view.frame.width

        scrollView.frame = view.bounds

        // ⭐ UPDATED contentSize with spacing
        scrollView.contentSize = CGSize(
            width: pageWidth,
            height: (pageHeight * CGFloat(pages.count)) +
                    (pageSpacing * CGFloat(pages.count - 1))
        )

        for (i, vc) in pages.enumerated() {
            if vc.view.superview == nil {
                addChild(vc)
                vc.view.backgroundColor = .systemGray5
                scrollView.addSubview(vc.view)
                vc.didMove(toParent: self)
            }

            // ⭐ UPDATED Y position with spacing
            vc.view.frame = CGRect(
                x: 0,
                y: (pageHeight + pageSpacing) * CGFloat(i),
                width: pageWidth,
                height: pageHeight
            )
        }
    }
    
    // ✅ THIS IS WHERE currentIndex COMES FROM
       func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
           let index = Int(round(scrollView.contentOffset.y / view.bounds.height))

           if index != lastIndex {
               lastIndex = index
               onPageChange?(index)
           }
       }
}
*/


/*  func boardClickApi(){
      
      let params = ["board_id":post.id ?? 0]
      
      URLhandler.sharedinstance.makeCall(url: Constant.shared.board_click, param: params,methodType: .post) { responseObject, error in
          
          if error == nil{
              
              let result = responseObject! as NSDictionary
              let status = result["code"] as? Int ?? 0
              let message = result["message"] as? String ?? ""
              
              if status == 200{
              }else{
              }
          }
      }
  }*/







struct TruncatableText: View {
    let text: String
    let lineLimit: Int
    let font: Font
    let onTruncationChange: (Bool) -> Void

    @State private var isTruncated = false

    var body: some View {
        Text(text)
            .font(font)
            .lineLimit(lineLimit)
            .background(
                Text(text)
                    .font(font)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .background(
                        GeometryReader { fullGeo in
                            Color.clear.onAppear {
                                DispatchQueue.main.async {
                                    let fullHeight = fullGeo.size.height
                                    let limitedHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight * CGFloat(lineLimit)
                                    let truncated = fullHeight > limitedHeight
                                    isTruncated = truncated
                                    onTruncationChange(truncated)
                                }
                            }
                        }
                    )
            )
    }
}


struct SeeMorePopupView: View {
    let title: String
    let description: String
    let onBuy: () -> Void

    var body: some View {
        VStack(spacing: 14) {

            Text(title)
                .font(.inter(.semiBold, size: 18))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)

            Text(description)
                .font(.inter(.medium, size: 16))
               .foregroundColor(Color(hex: "#666666"))

            Button(action: onBuy) {
                Text("Buy Now")
                    .font(.inter(.medium, size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hexString: "#FF9900"))
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}




final class DynamicHeightSheetController<Content: View>: UIViewController {

    private let host: UIHostingController<Content>

    init(content: Content) {
        self.host = UIHostingController(rootView: content)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        host.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let sheet = sheetPresentationController else { return }

        let targetHeight = host.view.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width,
                   height: UIView.layoutFittingCompressedSize.height)
        ).height

        sheet.detents = [
            .custom { _ in
                min(targetHeight + 16, UIScreen.main.bounds.height * 0.8)
            }
        ]

        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 22
        sheet.largestUndimmedDetentIdentifier = .none
    }
}


struct DynamicHeightSheet<Content: View>: UIViewControllerRepresentable {

    let content: Content

    func makeUIViewController(context: Context) -> UIViewController {
        DynamicHeightSheetController(content: content)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
