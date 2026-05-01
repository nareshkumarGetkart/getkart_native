//
//  CreateBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/12/25.
//

import SwiftUI
import FittedSheets
import Kingfisher
import UIKit

struct CreateBoardView: View {
    
    var navigationController: UINavigationController?
    var isFromEdit: Bool = false
    var boardId = 0
    
    // MARK: - Image States
    @State  var selectedImages: [Any] = []
    @State private var showImagePicker = false
    @State private var cropWrapper: CropImageWrapper? = nil

    // MARK: - Form States
    @State private var showCategoryPopup = false
    @State private var showCallToActionPopup = false
    @State private var showPostDurationPopup = false

    @State private var strUrl: String = ""
    @State private var strTitle: String = ""
    @State private var strDescription: String = ""
    @State private var strPrice: String = ""
    @State private var strOfferPrice: String = ""
    @State private var selectedCategory: String?
    @State private var selectedCategoryId: Int?
    @State private var isDataUploading: Bool = false
    @State private var selectedCallToAction: String?
    @State private var selectedCallToActionId: Int?
    @State private var boardObj: ItemModel?
    @State private var deletedImgIdArray = [String]()
    @State  var isPostValidate:Int = 0
    @State private var strPostDuration: String?

   
    // MARK: - Grid Layout
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
      
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                Button {
                    navigationController?.popToRootViewController(animated: true)
                    //navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(.label))
                }
                .frame(width: 40, height: 40)
                
                Text(isFromEdit ? "Edit Board" : "Create Board")
                    .font(.inter(.medium, size: 18))
                
                Spacer()
            }
            .frame(height: 44)
            .background(Color(.systemBackground))
            
            // MARK: - Body
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Board Images
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Board image")
                            .font(.inter(.medium, size: 16))
                        
                        Text("For the best results on all devices, use an image that's at least 4 MB or less.")
                            .font(.inter(.regular, size: 12))
                    }
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        
                        ForEach(0..<5, id: \.self) { index in
                            
                            ZStack(alignment: .topTrailing) {
                                
                                if index < selectedImages.count {
                                    
                                    // IMAGE SLOT
                                    GeometryReader { geo in
                                    if let img = selectedImages[index] as? UIImage{
                                            Image(uiImage: img)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geo.size.width,
                                                       height: geo.size.height)
                                                .clipped()
                                                .cornerRadius(12)
                                        }else if let imgUrl = selectedImages[index] as? String{
                                            
                                            AsyncImage(url: URL(string: imgUrl)) { img in
                                                img.resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geo.size.width,
                                                           height: geo.size.height)
                                                    .clipped()
                                                    .cornerRadius(12)
                                            } placeholder: {
                                               
                                            }
                                            
                                        }
                                       
                                    }
                                    
                                    Button {
                                        if isFromEdit{
                                            if let imgUrl = selectedImages[index] as? String{
                                                checkAndAppendData(strURL: imgUrl)
                                            }
                                        }
                                        selectedImages.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.orange)
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 6, y: -6)
                                    
                                } else {
                                    
                                    // PLUS SLOT
                                    Button {
                                        showImagePicker = true
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange, lineWidth: 1.5)
                                            
                                            Image(systemName: "plus")
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                            }
                            .frame(height: 110)
                        }
                    }

                    
                    // MARK: - Category
                    
                    HStack {
                        Text(selectedCategory ?? "Select Category")
                            .font(.inter(.regular, size: 16))
                        
                        Spacer()
                        
                        Image("arrow_dd")
                            .renderingMode(.template)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    .frame(height: 55)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground)))
                    .onTapGesture {
                        showCategoryPopup = true
                    }
                    
                    // MARK: - Title
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.inter(.regular, size: 16))
                        
                        TextField("Add your board title", text: $strTitle)
                            .padding(.horizontal)
                            .frame(height: 55)
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
                    
                    // MARK: - Description
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.inter(.regular, size: 16))
                        
                        TextEditor(text: $strDescription)
                            .frame(minHeight: 115, maxHeight: 190)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground)))
                            .onChange(of: strDescription) { newValue in
                                strDescription = String(newValue.prefix(400))
                            }
                        
                        HStack {
                            Spacer()
                            Text("\(strDescription.count)/400")
                                .font(.inter(.regular, size: 10))
                        }
                    }
                    
                    // MARK: - Price
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MRP Price")
                            .font(.inter(.regular, size: 16))
                        
                        TextField("00", text: $strPrice)
                            .padding(.horizontal)
                            .frame(height: 55)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground)))
                            .keyboardType(.numberPad)
                    }
                    // MARK: - Offer Price

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Offer Price").font(.inter(.regular, size: 16.0))
                        HStack{
                            TextField("00", text: $strOfferPrice).padding(.horizontal)
                                .onChange(of: strOfferPrice) { newValue in
                                // Allow only numbers
                                    if strPrice.count == 0{
                                        strOfferPrice = ""
                                        return
                                    }
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue {
                                    strOfferPrice = filtered
                                    return
                                }

                                guard let price = Int(strPrice),
                                      let offer = Int(filtered) else { return }

                                // Prevent offer price > actual price
                                if offer >= price {
                                    strOfferPrice =  "" //String(price)
                                }
                            }
                            Spacer()
                            if let price = Int(strPrice),
                               let offerPrice = Int(strOfferPrice),
                               price > 0 ,price >= offerPrice{

                                let differencePrice = price - offerPrice
                                let percentageOff = (differencePrice * 100) / price

                                Text("\(percentageOff)% Off").padding(.horizontal)
                                    .font(.inter(.regular, size: 16))
                                    .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
                            }

                        
                            
                        }.frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                            .background(
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                            
                        ).keyboardType(.numberPad).tint(Color(.systemOrange)).autocapitalization(.none)
                    }
                    
                    //MARK: Call to action
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Call to action")
                            .font(.inter(.regular, size: 16))
                        
                        HStack {
                            Text(selectedCallToAction ?? "Select Call to action")
                                .font(.inter(.regular, size: 16))
                            
                            Spacer()
                            
                            Image("arrow_dd")
                                .renderingMode(.template)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                        .frame(height: 55)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground)))
                        .onTapGesture {
                            showCallToActionPopup = true
                        }
                        Text("Choose where you want to redirect users.")
                            .font(.inter(.regular, size: 11)).foregroundColor(Color(.gray))
                    }
                    
                    
                    //MARK: post Duration action
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Post Duration")
                            .font(.inter(.regular, size: 16))
                        
                        HStack {
                            Text(strPostDuration ?? "Select Post duration")
                                .font(.inter(.regular, size: 16))
                            
                            Spacer()
                            
                            Image("arrow_dd")
                                .renderingMode(.template)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                        .frame(height: 55)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground)))
                        .onTapGesture {
                            showPostDurationPopup = true
                        }
                        Text("How long should your post stay active? (30,60,90 or 180 days)").font(.inter(.regular, size: 11)).foregroundColor(Color(.gray))
                    }
                    
                    
                    // MARK: - URL
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add URL")
                            .font(.inter(.regular, size: 16))
                        
                        TextField("Website", text: $strUrl)
                            .padding(.horizontal)
                            .frame(height: 55)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground)))
                            .keyboardType(.URL)
                        
                        Text("Add your business page link and let users discover you in just one click.")
                            .font(.inter(.regular, size: 11)).foregroundColor(Color(.gray))
                    }
                    
                    // MARK: - Submit
                    
                    let isFilled = isFromEdit ? true : !selectedImages.isEmpty
                    
                    Button {
                        if !isDataUploading {
                           validateField()
                        }
                    } label: {
                        Text(isFromEdit ? "Update" : "Submit")
                            .font(.inter(.medium, size: 18))
                            .foregroundColor(isFilled ? .white : .gray)
                    }
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(isFilled ? Color(hexString: "#FF9900")
                                : Color(hexString: "#DFDFDF"))
                    .cornerRadius(8)
                    
                }
                .padding()
            }
        }.onAppear {
            if isFromEdit && boardObj == nil{
                getBoardDetailApi()
            }
        }

        .background(Color(.systemGray6))
        .fullScreenCover(isPresented: $showImagePicker) {
            MultiImagePickerView(maxSelectionLimit: 5 - selectedImages.count, completion: { images in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cropWrapper = CropImageWrapper(images: images, type: nil)
                }
            })
        }
        
        .fullScreenCover(item: $cropWrapper) { wrapper in
            MultiImageCropperView(images:  wrapper.images) { images in
                selectedImages.append(contentsOf: images)
                self.checkNudityOfiMages(selectedImages: selectedImages)
                cropWrapper = nil
            } onCancel: {
                cropWrapper = nil
            }
        }
        .fullScreenCover(isPresented: $showCategoryPopup) {
            CategoryPopupView(
                isPresented: $showCategoryPopup,
                selectedCategory: $selectedCategory,selectedCategoryId: $selectedCategoryId
            )
            .presentationBackground(.clear)
        }
        
        
        .fullScreenCover(isPresented: $showCallToActionPopup) {
            CallToActionPopupView(
                isPresented: $showCallToActionPopup,
                selectedCategory: $selectedCallToAction,selectedCategoryId: $selectedCallToActionId,type:0
            )
            .presentationBackground(.clear)
        }
        .fullScreenCover(isPresented: $showPostDurationPopup) {
            DurationPopupView(isPresented: $showPostDurationPopup,
                              selectedOption: $strPostDuration)
                .presentationBackground(.clear)
        }
    }
    
    func validateField(){
        UIApplication.shared.endEditing()
       
        if selectedImages.count == 0 { //}&& !isFromEdit {
            
            AlertView.sharedManager.showToast(message: "Please upload board image")
            
        }else if selectedCategoryId == nil {
            
            AlertView.sharedManager.showToast(message: "Please select category of board")
            
        }else if strTitle.count < 3 || strTitle.count > 50 {
            // 3 to 50 characters
            AlertView.sharedManager.showToast(
                message: "Board title must be between 3 and 50 characters."
            )
        } else if strDescription.count < 20 || strDescription.count > 400 {
            // 50 to 150 characters
            AlertView.sharedManager.showToast(
                message: "Description must be between 20 and 400 characters."
            )
        } else if strPrice.count == 0 || ((Int(strPrice) ?? 0) <= 0) || strPrice.hasPrefix("0"){
            AlertView.sharedManager.showToast(message: "Please enter valid price")
            
        }else if selectedCallToActionId == nil {
            
            AlertView.sharedManager.showToast(message: "Please select call to action")
            
        }else if strPostDuration == nil {
            
            AlertView.sharedManager.showToast(message: "Please select post duration")
            
        }else if strUrl.count == 0 || !strUrl.isValidURLFormat() {
            AlertView.sharedManager.showToast(message: "Please add  valid url of your board")
        }else{
            isDataUploading = true
            createBoardApi()
        }
    }
    
    
    func checkNudityOfiMages(selectedImages: [Any]) {
        
        for img in selectedImages{
          
            if let pickedImage = img as? UIImage{
                
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
                                return
                            }else{
                                isPostValidate = 1
                              //  self.selectedImages = pickedImage
                            }
                        }
                    } else {
                        isPostValidate = 1
                        print("Image is safe")
                    }
                }

            }

        }
        
    }
    
    func checkAndAppendData(strURL:String){
        
        for anyData in (self.boardObj?.galleryImages ?? []){
            
            if anyData.image == strURL{
                deletedImgIdArray.append("\(anyData.id ?? 0)")
            }
        }
        
    }
    
    
    
    
    func updateDetails(){
        
        if boardObj != nil && selectedCategoryId == nil{
            strTitle = boardObj?.name ?? ""
            strDescription = boardObj?.description ?? ""
            strUrl = boardObj?.outbondUrl ?? ""
            strPrice = "\((boardObj?.price ?? 0.0).formatNumber())".replacingOccurrences(of: ",", with: "")
            if (boardObj?.specialPrice ?? 0.0) > 0{
                strOfferPrice = "\((boardObj?.specialPrice ?? 0.0).formatNumber())".replacingOccurrences(of: ",", with: "")
            }else{
                strOfferPrice = ""
            }
            selectedCategory = boardObj?.category?.name ?? ""
            selectedCategoryId = boardObj?.category?.id ?? 0
            
            selectedCallToAction = boardObj?.ctaLabel ?? ""
            selectedCallToActionId = boardObj?.ctaType ?? 0


            for item in self.boardObj?.galleryImages ?? []{
                self.selectedImages.append(item.image ?? "")
            }
            
            if boardObj?.status?.lowercased() != "approved"{
                isPostValidate = 0
            }else{
                isPostValidate = 1
            }
            
            if let postDuration = boardObj?.postDuration{
                strPostDuration = "\(postDuration) days"
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
    
    func createBoardApi(){
        
        var params:Dictionary<String,Any> = [:]
       
        params["name"] = strTitle
        params["category_id"] = selectedCategoryId ?? 0
        params["price"] = strPrice
        params["description"] = strDescription
        params["outbond_url"] = strUrl
        params["special_price"] = strOfferPrice
        params["isPostValidate"] = isPostValidate

        var strApiUrl = Constant.shared.create_board
        if isFromEdit{
            params["id"] = boardObj?.id ?? 0
            strApiUrl = Constant.shared.update_board
          //  params["isPostValidate"] = 0

        }
        
        params["board_type"] = 0 // 0=product,1=business
        params["cta_type"] =  selectedCallToActionId
        
        if let durationPost = strPostDuration{
            

            let cleaned = durationPost.replacingOccurrences(of: "days", with: "")
                             .trimmingCharacters(in: .whitespacesAndNewlines)

            if let days = Int(cleaned) {
                print(days)   // 180
                params["post_duration"] = days
            }
        }
        
        var imgNames = [String]()
        var galleryImagesData = [Data]()
        
        if isFromEdit{
            if deletedImgIdArray.count > 0{
                params["delete_item_image_id"] = deletedImgIdArray.joined(separator: ",")
            }
        }
        
        for anyData in selectedImages{
            
            if let img = anyData as? UIImage{
                if let imgData = img.wxCompress().pngData(){
                    galleryImagesData.append(imgData)
                    imgNames.append("gallery_images[]")
                }
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
                       // self.navigationController?.popViewController(animated: true)
                        self.navigationController?.popToRootViewController(animated: true)

                    }
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        })
    }
}

#Preview {
    CreateBoardView()
}


import PhotosUI

struct MultiImagePickerView: UIViewControllerRepresentable {
    
    var maxSelectionLimit = 5
    var completion: ([UIImage]) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        var config = PHPickerConfiguration()
        config.selectionLimit = maxSelectionLimit
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        let parent: MultiImagePickerView
        
        init(_ parent: MultiImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true)
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            images.append(image)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.completion(images)
            }
        }
    }
}

import Mantis

extension UIImage {
    func normalizedImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }
}

struct MultiImageCropperView: UIViewControllerRepresentable {

    var images: [UIImage]
    //var cropAspectRatio: CGSize
    var onFinished: ([UIImage]) -> Void
    var onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.createContainer()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    // MARK: - Coordinator
    class Coordinator: NSObject, CropViewControllerDelegate {

        var parent: MultiImageCropperView
        var currentIndex = 0
        var croppedImages: [UIImage] = []
        weak var cropVC: CropViewController?
        weak var containerVC: UIViewController?

        init(_ parent: MultiImageCropperView) {
            self.parent = parent
        }

        // MARK: Create Container
        func createContainer() -> UIViewController {

            let container = UIViewController()
            container.view.backgroundColor = .black
            containerVC = container

            currentIndex = 0

            guard parent.images.indices.contains(currentIndex) else {
                parent.onCancel()
                return container
            }

            showCropper(for: parent.images[currentIndex], in: container)

            return container
        }
        // MARK: Hide Mantis Default Buttons
        func hideMantisButtons(in view: UIView) {
            for sub in view.subviews {

                if let button = sub as? UIButton {

                    let title = button.title(for: .normal)?.lowercased() ?? ""
                    let accessibility = button.accessibilityLabel?.lowercased() ?? ""

                    if title.contains("cancel") || title.contains("done") ||
                       accessibility.contains("cancel") || accessibility.contains("done") {

                        button.isHidden = true
                        button.isUserInteractionEnabled = false
                    }
                }

                hideMantisButtons(in: sub)
            }
        }
                // MARK: Show Cropper
                func showCropper(for image: UIImage, in container: UIViewController) {

                    cropVC?.willMove(toParent: nil)
                    cropVC?.view.removeFromSuperview()
                    cropVC?.removeFromParent()

                    var config = Mantis.Config()

                    // ✅ IMPORTANT: must be true in iOS 18 / iOS 26+
                    config.showAttachedCropToolbar = true

                    let fixedImage = image.normalizedImage()
                    let cropVC = Mantis.cropViewController(image: fixedImage, config: config)
                    cropVC.delegate = self

                    container.addChild(cropVC)
                    container.view.addSubview(cropVC.view)
                    cropVC.didMove(toParent: container)

                    cropVC.view.translatesAutoresizingMaskIntoConstraints = false

                    NSLayoutConstraint.activate([
                        cropVC.view.topAnchor.constraint(equalTo: container.view.topAnchor),
                        cropVC.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
                        cropVC.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
                        cropVC.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor, constant: -100)
                    ])

                    self.cropVC = cropVC

                    addBottomBar(to: container)

                    // ✅ Hide default Mantis Done/Cancel buttons
                    cropVC.view.alpha = 0

                    DispatchQueue.main.async {
                        self.hideMantisButtons(in: cropVC.view)
                        cropVC.view.alpha = 1
                    }
                }

                // MARK: Bottom Bar
                func addBottomBar(to container: UIViewController) {

                    // remove old hosting controller (important)
                    container.children
                        .filter { $0 is UIHostingController<MultiCropBottomBar> }
                        .forEach {
                            $0.willMove(toParent: nil)
                            $0.view.removeFromSuperview()
                            $0.removeFromParent()
                        }

                    let bottomBar = MultiCropBottomBar(
                        currentIndex: currentIndex,
                        total: parent.images.count,
                        onCancel: { self.parent.onCancel() },
                        onPrevious: { self.previous() },
                        onNext: { self.next() }
                    )

                    let hosting = UIHostingController(rootView: bottomBar)
                    hosting.view.backgroundColor = UIColor.black

                    container.addChild(hosting)
                    container.view.addSubview(hosting.view)
                    hosting.didMove(toParent: container)

                    hosting.view.translatesAutoresizingMaskIntoConstraints = false

                    NSLayoutConstraint.activate([
                        hosting.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
                        hosting.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
                        hosting.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
                        hosting.view.heightAnchor.constraint(equalToConstant: 100)
                    ])

                    // keep bar always on top
                    container.view.bringSubviewToFront(hosting.view)
                }

                // MARK: Crop Delegate
                func cropViewControllerDidCrop(
                    _ cropViewController: CropViewController,
                    cropped: UIImage,
                    transformation: Transformation,
                    cropInfo: CropInfo
                ) {
                    croppedImages.append(cropped)
                }

                func cropViewControllerDidCancel(
                    _ cropViewController: CropViewController,
                    original: UIImage
                ) {
                    parent.onCancel()
                }

                // MARK: Actions
                func next() {

                    guard currentIndex < parent.images.count else { return }

                    cropVC?.crop()

                    if currentIndex < parent.images.count - 1 {
                        currentIndex += 1

                        if parent.images.indices.contains(currentIndex),
                           let container = containerVC {
                            showCropper(for: parent.images[currentIndex], in: container)
                        }

                    } else {
                        parent.onFinished(croppedImages)
                    }
                }

                func previous() {
                    if currentIndex > 0 {
                        currentIndex -= 1

                        if parent.images.indices.contains(currentIndex),
                           let container = containerVC {
                            showCropper(for: parent.images[currentIndex], in: container)
                        }
                    }
                }
            }
        }



struct MultiCropBottomBar: View {

    let currentIndex: Int
    let total: Int

    let onCancel: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {

            Button("Cancel") {
                onCancel()
            }
            .foregroundColor(Color(.systemOrange))

            Spacer()

            if currentIndex > 0 {
                Button("Previous") {
                    onPrevious()
                }
                .foregroundColor(Color(.systemOrange))
            }

            Spacer()

            Button(currentIndex == total - 1 ? "Done" : "Next") {
                onNext()
            }
            .foregroundColor(Color(.systemOrange))
            .bold()
        }
        .padding(.horizontal, 24)
        .frame(height: 100)
        .background(Color.black.opacity(0.95))
    }
}




struct DurationPopupView: View {

    @Binding var isPresented: Bool
    @Binding var selectedOption: String?

    let options = ["30 days", "60 days", "90 days","180 days"]

    var body: some View {

        ZStack {

            // Background Dim View
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }

                // Popup Card
                VStack(alignment: .leading, spacing: 20) {

                    ForEach(options, id: \.self) { option in
                        HStack(spacing: 16) {

                            Image(systemName: selectedOption == option ? "largecircle.fill.circle" : "circle")
                                .font(.system(size: 22))
                                .foregroundColor(selectedOption == option ? .orange : .gray)

                            Text(option)
                                .font(.inter(.medium, size: 18))
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedOption = option
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 370)
                .background(Color(.systemBackground))
                .cornerRadius(18)
                .shadow(radius: 10)
                .transition(.scale)
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}
