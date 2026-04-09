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

struct CreatePromotionalAdsView: View {
    
    var navigationController:UINavigationController?
    @State  var selectedImage: UIImage? = nil
    @State private var strUrl:String = ""
    @State private var strTitle:String = ""
    @State private var strDescription:String = ""
    @State private var showImagePicker = false
    @State private var showCropper = false
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

    var isFromEdit:Bool = false
    var boardId = 0
    @State   var isPostValidate:Int = 0

    var body: some View {
        HStack(spacing:0){
            Button {
                //navigationController?.popViewController(animated: true)
                self.navigationController?.popToRootViewController(animated: true)

            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
         
                Text(isFromEdit ? "Edit Promotional Ad" : "Create Promotional Ad").font(.inter(.medium, size: 18))
                    .foregroundColor(Color(UIColor.label))
            
            Spacer()

        }.frame(height:44).background(Color(UIColor.systemBackground))
            
        .onAppear {
            if isFromEdit && boardObj == nil{
                getBoardDetailApi()
            }
        }
            
        ScrollView{
            VStack(alignment:.leading,spacing: 20){
                VStack(alignment:.leading,spacing: 5){
                    if isFromEdit{
                        HStack{
                            Spacer()
                                Text("Create Promotional Ad").font(.inter(.medium, size: 18.0))
                            
                            Spacer()
                        }
                    }else{
                            
                            Text("Promotional Board Image").font(.inter(.medium, size: 16.0))
                            Text("For the best results on all devices, use an image/video that's at least 4 MB or less.").font(.inter(.regular, size: 12.0))
                    }
                }
                HStack{
                    Spacer()
                    VStack(alignment:.center){
                        
                        
                        Button {
                            showImagePicker = true
                            
                        } label: {
                            ZStack{
                                
                                if isFromEdit && selectedImage == nil{
                                    
                                    GeometryReader { geo in
                                        KFImage(URL(string:  boardObj?.image ?? ""))
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
                                            Text("Upload Image").font(.inter(.regular, size: 13.0))
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
                        
                        Text("Allowed file types: PNG, JPG, JPEG").multilineTextAlignment(.center).font(.inter(.medium, size: 11.0)).foregroundColor(Color.red)
                        
                        
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
           
            
            .sheet(isPresented: $showImagePicker) {
                ImagePickerPromotion(image: $selectedImage) {
                           showCropper = true
                       }
                   }
          
            .fullScreenCover(isPresented: $showCropper) {
                if let img = selectedImage {
                    
                    ImageCropperBoardView(
                        image: img,
                        onCropped: { croppedImage in
                           // self.selectedImage = croppedImage
                            self.checkNudityOfiMages(pickedImage: croppedImage)
                            showCropper = false
                        },
                        onCancel: {
                            showCropper = false
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $showCallToActionPopup) {
                CallToActionPopupView(
                    isPresented: $showCallToActionPopup,
                    selectedCategory: $selectedCallToACtion,selectedCategoryId: $selectedCallToACtionId,type:1
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
            
            AlertView.sharedManager.showToast(message: "Please upload image")
            
        }else if selectedCategoryId == nil {
            
            AlertView.sharedManager.showToast(message: "Please select category")
            
        }else if selectedCallToACtionId == nil {
            
            AlertView.sharedManager.showToast(message: "Please select call to action")
            
        }else if strUrl.count == 0 || !strUrl.isValidURLFormat() {
            AlertView.sharedManager.showToast(message: "Please add  valid url of your ad")
        }else{
            isDataUploading = true
            uploadFIleToServer()

        }
    }
    
    func checkNudityOfiMages(pickedImage: UIImage) {
        
        NudityChecker.detectNudity(in: pickedImage) { isExplicit, confidence in
           
            if isExplicit {
                print("Nudity detected with confidence: \(confidence!)")
                DispatchQueue.main.async {
                    
                    if (confidence ?? 0) > Float(Local.shared.iosNudityThreshold) {
                        isPostValidate = 0
                         AlertView.sharedManager.displayMessageWithAlert(
                         title: "!Alert",
                         msg: "Uploading or sharing any form of vulgar or offensive content on this platform is strictly prohibited."
                         )
                    }else{
                        isPostValidate = 1
                        self.selectedImage = pickedImage
                    }
                }
            } else {
                isPostValidate = 1
                print("Image is safe")
            }
        }
        
    }

    func updateDetails(){
        if boardObj != nil && selectedCategoryId == nil{
            strTitle = boardObj?.name ?? ""
            strDescription = boardObj?.description ?? ""
            strUrl = boardObj?.outbondUrl ?? ""
            selectedCategory = boardObj?.category?.name ?? ""
            selectedCategoryId = boardObj?.category?.id ?? 0
           
            selectedCallToACtion = boardObj?.ctaLabel ?? ""
            selectedCallToACtionId = boardObj?.ctaType ?? 0
            
           
            if boardObj?.status?.lowercased() != "approved"{
                isPostValidate = 0
            }else{
                isPostValidate = 1
            }
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
        params["isPostValidate"] = isPostValidate

        if isFromEdit{
            params["id"] = boardObj?.id ?? 0
            strApiUrl = Constant.shared.update_promotional_board
           // params["isPostValidate"] = 0

        }
        
        params["board_type"] = 1 // 0=product,1=business,2=board video,3=idea
        params["cta_type"] =  selectedCallToACtionId
        params["category_id"] = selectedCategoryId ?? 0
        params["outbond_url"] = strUrl
        params["name"] = ""
        
        var imgNames = [String]()
        var galleryImagesData = [Data]()
                    
        if let img = selectedImage{
            if let imgData = img.wxCompress().pngData(){
                galleryImagesData.append(imgData)
                imgNames.append("gallery_images[]")
            }
        }
       
        URLhandler.sharedinstance.uploadImageArrayWithParameters(imageData: nil, imageName: "", imagesData: galleryImagesData, imageNames: imgNames, url:strApiUrl , params: params, completionHandler: { responseObject, error in
        
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
                        //self.navigationController?.popViewController(animated: true)
                        self.navigationController?.popToRootViewController(animated: true)

                    }
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        })
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
}

#Preview {
    CreatePromotionalAdsView()
}
