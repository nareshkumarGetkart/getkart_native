//
//  BoardDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//

import SwiftUI


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
                  }
                  .frame(width: 40, height: 40)

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
              .padding(.horizontal)
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
                        
                        //print("Liked:", isLiked, "BoardId:", boardId)
                    }) }
                    ,
                        onPageChange: { index in
                            currentIndex = index
                            print("====\(currentIndex)")
                            boardClickApi(post: listArray[index])

                        })//.id(listArray.last?.id ?? 0) //.id(listArray.count)
                    
                    .onChange(of:currentIndex) { newIndex in
                        if newIndex == listArray.count - 1 {
                            getBoardListApi()
                        }
                        
                        
                    }
            }
            Spacer()
        }
        .onAppear {
           // UIScrollView.appearance().isPagingEnabled = true
            if listArray.count == 0{
                getBoardListApi()
                boardClickApi(post: itemObj)
            }
        }
        
        
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
                

               /* if obj.data != nil , (obj.data?.data ?? []).count > 0 {
                    self.listArray.append(contentsOf:  obj.data?.data ?? [])
                        
                }
                                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isDataLoading = false
                    self.page += 1
                })*/
                
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

    var body: some View {

        VStack(spacing: 0) {

            // IMAGE
            GeometryReader { geo in
                AsyncImage(url: URL(string: post.image ?? "")) { img in
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(
                            color: Color.black.opacity(0.10),
                            radius: 7,
                            x: 0,
                            y: 2
                        )
                } placeholder: {
                    Color.black
                }
            }
            .cornerRadius(10)

            // BOTTOM CARD (ALWAYS VISIBLE)
            bottomCard.padding()
        }
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .padding(8)
    }

    private var bottomCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack{
                HStack(spacing:3){
                    Button {
                        post.isLiked?.toggle()
                        manageLikeDislikeApi()
                    } label: {
                        let imgStr = (post.isLiked == true) ? "like_fill" : "like"
                        Image(imgStr).foregroundColor(Color(.label))
                    }
                    
                    Text("\(post.totalLikes ?? 0)").font(Font.inter(.regular, size: 14)).foregroundColor(Color(.label))
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
                                UIPasteboard.general.string = ShareMedia.itemUrl + "/board/\(post.id ?? 0)"
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
                Text(post.description ?? "") .font(.inter(.regular, size: 14))
               
                
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
            
            Button {
                outboundClickApi(strURl: post.outbondUrl ?? "")
            } label: {
                
                Text("Buy Now").font(.inter(.semiBold, size: 16.0)).foregroundColor(.white)
                  
            }.frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                .background(Color(hexString: "#FF9900")) .cornerRadius(8).padding([.bottom,.top])
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
        
        if let url = URL(string: strURl)  {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL")
            }
        }
      
    }
    
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
                        //  .frame(maxWidth: UIScreen.ft_width(), maxHeight: .infinity)
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
