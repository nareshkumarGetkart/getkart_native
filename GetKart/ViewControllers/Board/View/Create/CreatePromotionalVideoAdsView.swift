//
//  CreatePromotionalAdsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/02/26.
//

import SwiftUI
import FittedSheets
import Kingfisher
import AVFoundation
import UIKit

struct CreatePromotionalVideoAdsView: View {
    
    var navigationController:UINavigationController?
    @State private var strUrl:String = ""
    @State private var strTitle:String = ""
    @State private var showVideoPicker = false
    @State private var showSheetpackages = false
    @State private var showBuySheetpackages = false
    @State private var selectedPkgObj:PlanModel?
    @State private var showCategoryPopup = false
    @State private var showCallToActionPopup = false
    @State private var selectedCategory: String?
    @State private var selectedCategoryId: Int?
    @State private var isDataUploading: Bool = false
    @State private var selectedCallToACtion: String?
    @State private var selectedCallToACtionId: Int?
    @State private var boardObj:ItemModel?
    @State  var videoSelected: AVURLAsset?
    @State  private var selectedImage: UIImage? = nil

    var isFromEdit:Bool = false
    var boardId = 0
    @State  private var isFirstTime = true

    var body: some View {
        HStack(spacing:0){
            Button {
                self.navigationController?.popToRootViewController(animated: true)

            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
         
                Text(isFromEdit ? "Edit Video Ad" : "Create Video Ad").font(.inter(.medium, size: 18))
                    .foregroundColor(Color(UIColor.label))
            Spacer()

        }.frame(height:44).background(Color(UIColor.systemBackground))
            
            .onAppear {
                
                if isFromEdit && boardObj == nil{
                    getBoardDetailApi()
                }else{
                    if selectedImage == nil{
                        if let asset = videoSelected{
                            selectedImage = generateThumbnail(from: asset)
                        }
                    }
                    
                    if isFirstTime{
                        showVideoPicker = true
                        isFirstTime = false
                    }
                }
            }
            
        ScrollView{
            VStack(alignment:.leading,spacing: 20){
                VStack(alignment:.leading,spacing: 5){
                    if isFromEdit{
                        HStack{
                            Spacer()
                          
                                Text("Create Video Ad").font(.inter(.medium, size: 18.0))
                            Spacer()
                        }
                    }else{
                       
                            Text("Board Video Ad").font(.inter(.medium, size: 16.0))
//                            Text("For best results, upload a video up to 50 MB with a maximum length of 30 seconds.").font(.inter(.regular, size: 12.0))
                            (
                                Text("For best results, upload a video up to ")
                                + Text("50 MB").bold()
                                + Text(" with a maximum length of ")
                                + Text("30 seconds").bold()
                                + Text(".")
                            )
                            .font(.inter(.regular, size: 12.0))

                    }
                }
                HStack{
                    Spacer()
                    VStack(alignment:.center){
                        
                        
                        Button {
                            showVideoPicker = true
                            
                        } label: {
                            ZStack{
                                
                                if isFromEdit && selectedImage == nil{
                                    
                                    GeometryReader { geo in
                                        KFImage(URL(string: boardObj?.image ?? ""))
                                            .placeholder {
                                                Image("getkartplaceholder")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geo.size.width, height: geo.size.height)
                                                    .clipped() //  Important to crop overflowing area
                                                    .cornerRadius(8)
                                            }
                                        
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                    
                                }else{
                                    if let img = selectedImage{
                                        
                                        GeometryReader { geo in
                                            
                                            Image(uiImage: img)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geo.size.width, height: geo.size.height)
                                                .clipped()
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                VStack{
                                    
                                    if isFromEdit {
                                        
                                        Image("uploadBanner").renderingMode(.template).foregroundColor(Color(.white))
                                        Text("Upload Video").font(.inter(.regular, size: 13.0))
                                            .foregroundColor(Color(.white))
                                    }else{
                                        Image("gallery")
                                        Text("Select file").font(.inter(.regular, size: 13.0)).foregroundColor(Color(hexString: "#888888"))
                                    }
                                    
                                    
                                }.opacity(selectedImage == nil ? 1 : 0) // hide label over image
                            }.frame(maxWidth: 220, minHeight: 260, maxHeight: 260)
                                .background(
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemBackground))
                                    
                                )
                                .overlay{
                                    RoundedRectangle(cornerRadius: 8.0).stroke(Color(hexString: "#DADADA"), lineWidth: 1.0)
                                }
                        }
                                                
                    }
                    Spacer()
                    
                }
                
                
            HStack{
                Text(selectedCategory ?? "Select Category").font(.inter(.regular, size: 16.0)).foregroundColor(Color(.label))
                    Spacer()
                Image("arrow_dd").renderingMode(.template)
                        .foregroundColor(Color(.systemOrange))
                }.padding(.horizontal).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55).background(
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                    
                ).onTapGesture {
                    showCategoryPopup = true

                }
                
                // MARK: - Title
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.inter(.regular, size: 16))
                    
                    TextField("Add your board title", text: $strTitle)
                        .padding(.horizontal)
                        .frame(height: 55)
                        .tint(Color(.systemOrange))
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground)))
                        .onChange(of: strTitle) { newValue in
                            if newValue.count > 50 {
                                strTitle = String(newValue.prefix(50))
                            }
                        }
                    
                    HStack {
                        Spacer()
                        Text("\(strTitle.count)/50")
                            .font(.inter(.regular, size: 10))
                    }
                }

               
                VStack(alignment:.leading,spacing: 8){
                    Text("Call to action").font(.inter(.regular, size: 16.0))
                    
                    HStack{
                        Text(selectedCallToACtion ?? "Select Call to action").font(.inter(.regular, size: 16.0)).foregroundColor(Color(.label))
                            Spacer()
                        Image("arrow_dd").renderingMode(.template)
                                .foregroundColor(Color(.systemOrange))
                        }.padding(.horizontal).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55).background(
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                            
                        ).onTapGesture {
                            showCallToActionPopup = true

                        }
                    Text("Choose where you want to redirect users.").font(.inter(.regular, size: 10.0)).foregroundColor(Color(.gray))
                }
                
                VStack(alignment:.leading,spacing: 8){
                    Text("Add URL").font(.inter(.regular, size: 16.0))
                    TextField("Website", text: $strUrl).padding(.horizontal).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                    ).keyboardType(.URL)
                      .tint(Color(.systemOrange))
                      .autocapitalization(.none)
                      .disableAutocorrection(true)
                      .textInputAutocapitalization(.never)
                    Text("Add your business page link and let users discover you in just one click.").font(.inter(.regular, size: 10.0)).foregroundColor(Color(.gray))
                }

                
                let isFilled =  (isFromEdit) ? true : ((selectedImage != nil) ? true : false)
               Button {
                   
                 //  if isFilled{
                   if !isDataUploading{
                       validateField()
                   }
                   //}
               } label: {
                   let strText = (isFromEdit) ? "Update" : "Submit"
                   Text(strText).font(.inter(.medium, size: 18.0)).foregroundColor(isFilled ? .white : .gray)
                     
               }.frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                    .background(isFilled ? Color(hexString: "#FF9900") : Color(hexString: "#DFDFDF")) .cornerRadius(8)
                
                Spacer()
            }.padding()
            
            
        }.scrollIndicators(.hidden, axes: .vertical)
        .background(Color(UIColor.systemGray6))
        
        .fullScreenCover(isPresented: $showCategoryPopup) {
            CategoryPopupView(
                isPresented: $showCategoryPopup,
                selectedCategory: $selectedCategory,selectedCategoryId: $selectedCategoryId
            )
            .presentationBackground(.clear)
        }
           
            
        .sheet(isPresented: $showVideoPicker) {
            
            
            VideoPickerView(maxDuration: 30) { assets in
                //videoSelected = assets
                self.videoSelected = assets
                self.selectedImage = generateThumbnail(from: assets)
            } onCancel: {
                
            }
        }
        
          
            .fullScreenCover(isPresented: $showCallToActionPopup) {
                CallToActionPopupView(
                    isPresented: $showCallToActionPopup,
                    selectedCategory: $selectedCallToACtion,selectedCategoryId: $selectedCallToACtionId,type:2
                )
                .presentationBackground(.clear)
               
            }
            .sheet(isPresented: $showSheetpackages) {
                if #available(iOS 16.0, *) {
                    PromotionPackagesView(navigationController: self.navigationController, packageSelectedPressed: {selPkgObj in
                        selectedPkgObj = selPkgObj
                        self.presentPayView(planObj: selPkgObj)
                        //showBuySheetpackages = true
                        
                        
                    })
                    .presentationDetents([.fraction(0.6)]) //  50% screen height
                    .presentationDragIndicator(.visible)
                } else {
                    // Fallback on earlier versions
                }   // Optional drag handle
            }
            
            .sheet(isPresented: $showBuySheetpackages) {
                
                if #available(iOS 16.0, *) {
                    
                    BuyPromotionPackageView(navigationController: self.navigationController, buyButtonPressed: {
                        
                        //Call upload pic api
                        
                    }, selPkgObj: selectedPkgObj)
                   
                    .presentationDetents([.fraction(0.25)]) // 📏 50% screen height
                    .presentationDragIndicator(.visible)
                } else {
                    // Fallback on earlier versions
                }
            }
        
        
    }
    
    
    func validateField(){
        UIApplication.shared.endEditing()
       
        if selectedImage == nil && !isFromEdit {
            
            AlertView.sharedManager.showToast(message: "Please upload video")
            
        }else if selectedCategoryId == nil {
            
            AlertView.sharedManager.showToast(message: "Please select category")
            
        }else if strTitle.count < 3 || strTitle.count > 50 {
            // 3 to 50 characters
            AlertView.sharedManager.showToast(
                message: "Ad title must be between 3 and 50 characters."
            )
        }else if selectedCallToACtionId == nil {
            
            AlertView.sharedManager.showToast(message: "Please select call to action")
            
        }else if strUrl.count == 0 || !strUrl.isValidURLFormat() {
            AlertView.sharedManager.showToast(message: "Please add  valid url of your ad")
        } else{
            isDataUploading = true
            uploadFIleToServer()

        }
    }
        
    func updateDetails(){
        if boardObj != nil && selectedCategoryId == nil{
            strTitle = boardObj?.name ?? ""
            strUrl = boardObj?.outbondUrl ?? ""
            selectedCategory = boardObj?.category?.name ?? ""
            selectedCategoryId = boardObj?.category?.id ?? 0
            
            selectedCallToACtion = boardObj?.ctaLabel ?? ""
            selectedCallToACtionId = boardObj?.ctaType ?? 0
            
        }
    }
     func getBoardDetailApi(){
       
        let strApiUrl = Constant.shared.get_myboard_details + "?board_id=\(boardId)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strApiUrl,loaderPos: .mid) { (obj:SingleItemParse) in
            
            if obj.code == 200
            {
                if obj.data != nil  {
                    if let board = obj.data?.first{
                        DispatchQueue.main.async {
                            self.boardObj = board
                            self.updateDetails()
                        }
                    }
                }
                
            }else{
                
            }
        }
    }
    
    func uploadFIleToServer(){
        
        var params:Dictionary<String,Any> = [:]
     
        var strApiUrl = Constant.shared.create_promotional_board
        if isFromEdit{
            params["id"] = boardObj?.id ?? 0
            strApiUrl = Constant.shared.update_promotional_board
        }
        
        params["board_type"] = 2 // 0=product,1=business
        params["cta_type"] =  selectedCallToACtionId
        params["category_id"] = selectedCategoryId ?? 0
        params["outbond_url"] = strUrl
        params["name"] = strTitle

        var selectedVideoArray = [AVURLAsset]()
        if let asset = videoSelected{
            selectedVideoArray.append(asset)
        }
   
    
        
        URLhandler.sharedinstance.uploadVideoArrayWithParameters(videoAssets: selectedVideoArray, videoParamName: "gallery_images[]", url: strApiUrl, params: params) { responseObject, error in
      
            self.isDataUploading = false

            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200{
                    if self.isFromEdit{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshMyBoardsScreen.rawValue), object: nil, userInfo: nil)
                    }
                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: (self.navigationController?.topViewController)!) { title, index in
                     
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        }//)
    }
    
   
    func presentPayView(planObj:PlanModel){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "PayPlanVC")
        as! PayPlanVC
        controller.strUrl = strUrl
        controller.paymentFor = .bannerPromotion

        
        controller.callbackPaymentSuccess = { (isSuccess) -> Void in
            
            if controller.sheetViewController?.options.useInlineMode == true {
                controller.sheetViewController?.attemptDismiss(animated: true)
            } else {
                controller.dismiss(animated: true, completion: nil)
            }
            
            if isSuccess == true {
                let vc = UIHostingController(rootView: PlanBoughtSuccessView(navigationController: self.navigationController))
                vc.modalPresentationStyle = .overFullScreen // Full-screen modal
                vc.modalTransitionStyle = .crossDissolve   // Fade-in effect
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
        
        let useInlineMode = (self.navigationController?.topViewController?.view)! != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.3
        if UIDevice().hasNotch{
            fixedSize = 0.27
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.37
            }
        }
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.percent(Float(fixedSize)),.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
        sheet.allowGestureThroughOverlay = false
        // sheet.dismissOnOverlayTap = false
        sheet.cornerRadius = 15
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
    
 

    func generateThumbnail(from asset: AVURLAsset) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail generation failed: \(error)")
            return nil
        }
    }
}

#Preview {
    CreatePromotionalVideoAdsView()
}
