//
//  CreateAdFirstView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/07/25.
//

import SwiftUI

enum PictureType{
    case main
    case other
}


enum Field: Hashable {
    case title
    case description
    case price
    case phone
    case videoLink
}


struct CreateAdFirstView: View {
    var navigationController:UINavigationController?
    
    var objCategory: CategoryModel?
    var objSubCategory:Subcategory?
    var strCategoryTitle = ""
    var strSubCategoryTitle = ""
    var category_ids = ""
    @State var objViewModel:PostAdsViewModel = PostAdsViewModel()
    @State  private var params:Dictionary<String,Any> = [:]
    @State private  var delete_item_image_id:String = ""
    var popType:PopType? = .createPost
    var itemObj:ItemModel?
    private var imgName = "image"
    @State private var imgDataMain:Data?
    @State private var selImgDataArray:Array<Data> = [Data]()
    @State private var strAdTitle = ""
    @State private var strAdDescription = ""
    @State private var price = ""
    @State private var phonenumber = ""
    @State private var strVideoLink = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showPicker = false
    @State private var selectedMainImage:UIImage?
    @State private var isError = false
    @State private var selectedPictureType:PictureType = .main
    @FocusState private var focusedField: Field?
   
    
    init(navigationController: UINavigationController? = nil, objCategory: CategoryModel? = nil, objSubCategory: Subcategory? = nil, strCategoryTitle: String = "", strSubCategoryTitle: String = "", category_ids: String = "", popType: PopType? = .createPost, itemObj: ItemModel? = nil) {
        self.navigationController = navigationController
        self.objCategory = objCategory
        self.objSubCategory = objSubCategory
        self.strCategoryTitle = strCategoryTitle
        self.strSubCategoryTitle = strSubCategoryTitle
        self.category_ids = category_ids
        self.popType = popType
        self.itemObj = itemObj
    }
    
    var body: some View {
        HStack{
            
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Post Detail").font(.manrope(.bold, size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
            .onAppear{
                if  (params[AddKeys.all_category_ids.rawValue] == nil){
                    self.updateData()
                    self.downloadImgData()
                }
            }
     
        ScrollView{
            
            VStack(alignment:.leading,spacing: 8){
                Text("You're almost there!").font(.manrope(.bold, size: 17))
                HStack{
                    
                    Text(strCategoryTitle).foregroundColor(Color(.label)).font(.manrope(.regular, size: 14))
                    
                    if strSubCategoryTitle.count > 0 {
                        
                        Text("> \(strSubCategoryTitle)").foregroundColor(Color(.systemOrange)).font(.manrope(.regular, size: 14))
                    }
                    Spacer()
                }.padding(.bottom)
                
                VStack(alignment:.leading){
                    let borderColor = (focusedField == .title) ? Color.gray : ((isError && strAdTitle.trim().count < 2) ? Color.red : Color.gray)
                    Text("Add Title").font(.manrope(.regular, size: 16))
                    TextField("", text: $strAdTitle).padding(.horizontal,10).frame(height:50).focused($focusedField, equals: .title)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 0.5)
                        }.tint(.orange)
                        .onChange(of: strAdTitle) { newValue in
                            
                            if newValue.count > 50 {
                                strAdTitle = String(newValue.prefix(50))
                            }
                        }
                    HStack{
                        if isError && strAdTitle.trim().count < 2{
                            Text("Field must not be empty").foregroundColor(Color.red).font(.manrope(.regular, size: 14))
                        }
                        Spacer()
                        Text("50/\(strAdTitle.count)").font(.manrope(.regular, size: 13))
                    }
                }//.padding(.bottom)
                
                VStack(alignment:.leading){
                    Text("Description").font(.manrope(.regular, size: 16))
                    let borderColor = ( isError && strAdDescription.trim().count == 0 ||  strAdDescription.trim().count > 4000) ? Color.red : Color.gray
                    TextEditor(text: $strAdDescription).frame(height:160)
                       
                        .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 0.5)
                        }.tint(.orange).cornerRadius(8.0)
                    HStack{
                        if isError && strAdDescription.trim().count == 0 ||  strAdDescription.trim().count > 4000{
                            Text("Please enter description under 4000 characters").foregroundColor(Color.red).font(.manrope(.regular, size: 14))
                        }
                        Spacer()
                        Text("4000/\(strAdDescription.count)").font(.manrope(.regular, size: 13))
                    }
                }//.padding(.bottom)
                
                VStack(alignment:.leading){
                    Text("Main Picture(Max 3MB)").font(.manrope(.regular, size: 16))
                    
                    if selectedMainImage == nil {
                        Button(action:{
                            selectedPictureType = .main
                            showPicker = true
                            
                        },
                               label:{
                            Text("Add Main Picture").font(.manrope(.medium, size: 16)).foregroundColor(Color(.label)).frame(maxWidth: .infinity).frame(height:50) .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                            ).overlay {
                                RoundedRectangle(cornerRadius: 8).stroke((isError) ? Color.red : Color.gray, lineWidth:0.5)
                            }
                          
                        }
                        )
                        
                        if isError{
                            Text("Please add main picture").foregroundColor(Color.red).font(.manrope(.regular, size: 13))
                        }
                    }else{
                        
                        
                        ZStack(alignment: .topTrailing){
                            
                            if let img = selectedMainImage{
                                Image(uiImage: img)
                                    .resizable().frame(width: 100, height: 100)
                                    .scaledToFit().cornerRadius(8.0)
                            }
                            
                            Button {
                                selectedMainImage = nil
                            } label: {
                                Image("Cross").frame(width: 26, height: 26).background(Color(.systemOrange)).cornerRadius(5.0).padding(2)
                            }
                            
                            
                        }.frame(width: 100, height: 100).overlay {
                            RoundedRectangle(cornerRadius: 8.0).stroke(Color.gray, lineWidth: 1.0)
                        }
                        
                    }
                    
                }.padding(.bottom)
                
                VStack(alignment:.leading){
                    Text("Other Picture(Max 5 images)").font(.manrope(.regular, size: 16))
                    
                    if selectedImages.count == 0 {
                        Button(action:{
                            selectedPictureType = .other
                            showPicker = true
                        },
                               label:{
                            Text("Add Other Picture").font(.manrope(.medium, size: 16)).foregroundColor(Color(.label)).frame(maxWidth: .infinity).frame(height:50) .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                            ).overlay {
                                RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth:0.5)
                            }
                        }
                        )
                    }else{
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(Array(selectedImages.enumerated()), id: \.element) { index, img in
                                
                                ZStack(alignment: .topTrailing){
                                    
                                    Image(uiImage: img)
                                        .resizable().frame(width: 100, height: 100)
                                        .scaledToFit().cornerRadius(8.0)
                                    
                                    Button {
                                        
                                        
                                        if self.popType == .editPost {
                                            self.updateGalleryDeletedId(index: index)
                                        }
                                        selectedImages.remove(at: index)

                                    } label: {
                                        Image("Cross").frame(width: 26, height: 26).background(Color(.systemOrange)).cornerRadius(5.0).padding(2)
                                    }
                                    
                                    
                                }.frame(width: 100, height: 100).overlay {
                                    RoundedRectangle(cornerRadius: 8.0).stroke(Color.gray, lineWidth: 1.0)
                                }
                                
                            }
                            
                            // Upload Button
                            if selectedImages.count < 5 {
                                Button(action: {
                                    selectedPictureType = .other
                                    showPicker = true
                                 
                                    
                                }) {
                                    Text("Upload\nPhoto").foregroundColor(Color(.label))
                                        .multilineTextAlignment(.center)
                                        .frame(width: 100, height: 100)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8).overlay {
                                            RoundedRectangle(cornerRadius: 8.0).stroke(Color.gray,lineWidth: 1.0)
                                        }
                                }
                            }
                        }
                        
                    }
                    
                }.padding(.bottom)
                
                VStack(alignment:.leading){
                    let borderColor =  (focusedField == .price) ? Color.gray : (isError && price.trim().count == 0) ? Color.red : Color.gray

                    Text("Price").font(.manrope(.regular, size: 16))
                    TextField("", text: $price).padding(.horizontal,10).frame(height:50) .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                    ).overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 0.5)
                    }.tint(.orange).keyboardType(.numberPad)
                        .onChange(of: price) { newValue in
                            
                            if newValue.count > 9 {
                                price = String(newValue.prefix(9))
                            }
                        }.focused($focusedField, equals: .price)
                    HStack{
                        if isError && price.trim().count == 0 {
                            Text("Please enter price").foregroundColor(Color.red).font(.manrope(.regular, size: 14))
                        }
                        Spacer()
                        Text("9/\(price.count)").font(.manrope(.regular, size: 13))
                    }
                }//.padding(.bottom)
                
                
                VStack(alignment:.leading){
                    let borderColor =  (focusedField == .phone) ?  Color.gray : (isError && phonenumber.trim().count < 10) ? Color.red : Color.gray

                    Text("Phone Number").font(.manrope(.regular, size: 16))
                    TextField("", text: $phonenumber).padding(.horizontal,10)
                        .frame(height:50)
                        .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                    ).overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 0.5)
                    }.tint(.orange).keyboardType(.numberPad)
                        .onChange(of: phonenumber){newValue in
                        
                            if newValue.count > 11{
                            phonenumber = String(newValue.prefix(11))
                        }
                        }.focused($focusedField, equals: .phone)
                    HStack{
                        if isError && phonenumber.trim().count < 10 {
                            Text("Please enter valid phone number").foregroundColor(Color.red).font(.manrope(.regular, size: 13))
                        }
                        Spacer()
                        Text("11/\(phonenumber.count)").font(.manrope(.regular, size: 13))
                    }
                    
                }//.padding(.bottom)
                
                
                VStack(alignment:.leading){
                    Text("Video Link(Optional)").font(.manrope(.regular, size: 16))
                    TextField("", text: $strVideoLink).padding(.horizontal,10).frame(height:50) .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                    ).overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color(.gray), lineWidth: 0.5)
                    }.tint(.orange)
                }//.padding(.bottom,30)
                
                
                
            }.padding()
        }.background(Color(.secondarySystemBackground))
        
            .sheet(isPresented: $showPicker) {
                
                if selectedPictureType == .main{
                    
                    ImagePickerView(selectedImages: Binding(
                            get: { selectedMainImage != nil ? [] : [] },
                            set: { selectedMainImage = $0.first }
                        ), maxSelectLimit: 1)
                    
                }else{
                    let numberOfImages =  5 - selectedImages.count
                    ImagePickerView(selectedImages: $selectedImages,maxSelectLimit:numberOfImages)
                }
            }
        
        Button(action:{
            self.validateFields()
        }) {
            Text("Next").font(.manrope(.medium, size: 17)).foregroundColor(Color(.label)).frame(maxWidth: .infinity).frame(height:50).background(Color(.orange))
                .cornerRadius(8.0).padding([.leading,.trailing])
        }//.padding(.bottom)
        
    }
    
    
    func updateGalleryDeletedId(index:Int){
        let data = selectedImages[index].pngData()
        for obj in self.itemObj?.galleryImages ?? []{
            if obj.imgData == data {
                if self.delete_item_image_id.count == 0 {
                    self.delete_item_image_id = "\(obj.id ?? 0)"
                }else {
                    self.delete_item_image_id = self.delete_item_image_id + ",\(obj.id ?? 0)"
                }
            }
        }
        print("delete_item_image_id: ",delete_item_image_id)
    }
    
    func validateFields(){
        
        if strAdTitle.count == 0{
            isError = true
        }else if strAdDescription.count == 0 || strAdDescription.count > 4000{
            isError = true
        }else if selectedMainImage == nil{
            isError = true
        }else if price.count == 0 || Int(price.trim()) == 0 {
            isError = true
        }else if phonenumber.count < 10{
            isError = true

        }else{
            params[AddKeys.name.rawValue] = strAdTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            params[AddKeys.price.rawValue] = price.trimmingCharacters(in: .whitespacesAndNewlines)
            params[AddKeys.contact.rawValue] = phonenumber.trimmingCharacters(in: .whitespacesAndNewlines)
            params[AddKeys.video_link.rawValue] = strVideoLink.trimmingCharacters(in: .whitespacesAndNewlines)
            params[AddKeys.description.rawValue] = strAdDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                        
            isError = false
           self.params["slug"] = self.generateSlug(self.params[AddKeys.name.rawValue] as? String ?? "")
               
            if self.objViewModel.dataArray?.count == 0 {
                    //If no any custom field
                 
                    if popType == .createPost {
                        
                        var galleryImgName = [String]()
                        
                        for _ in 0..<self.selectedImages.count {
                            galleryImgName.append("gallery_images[]")
                        }
                        
                        var galleryImgData = [Data]()
                        for image in selectedImages {
                            if let imgData = image.wxCompress().pngData(){
                                galleryImgData.append(imgData)
                            }
                        }

                        
                        let vc = ConfirmLocationHostingController(rootView: ConfirmLocationCreateAdd(imgData: self.selectedMainImage?.pngData(), imgName: self.imgName, gallery_images: galleryImgData, gallery_imageNames: galleryImgName, navigationController: self.navigationController, popType: self.popType, params: self.params))
                        self.navigationController?.pushViewController(vc, animated: true)

                    }else{
                        
                        var pushImgData = self.selectedMainImage?.wxCompress().pngData()
                        var pushImgName = self.imgName
                        var pushGalleryImg : Array<Data> = []
                        var pushGallery_imageNames : Array<String> = []
                        
                        if delete_item_image_id.count > 0 {
                            params["delete_item_image_id"] = delete_item_image_id.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        if let imgData = selectedMainImage?.wxCompress().pngData(){
                            
                            if self.imgDataMain != imgData {
                                pushImgData = imgData
                                pushImgName = self.imgName
                            }
                            
                        }
                        //send only images that is updated by user
                        for ind in 0..<(self.selImgDataArray.count){
                            let data = self.selImgDataArray[ind]
                            var found = false
                            for index in 0..<(self.itemObj?.galleryImages?.count ?? 0){
                                if let obj = self.itemObj?.galleryImages?[index] {
                                    
                                    if obj.imgData == data {
                                        found = true
                                        break
                                    }
                                }
                            }
                            
                            if found == false {
                                pushGalleryImg.append(data)
                                pushGallery_imageNames.append("gallery_images[]")
                            }
                        }
                        
                        let vc = ConfirmLocationHostingController(rootView: ConfirmLocationCreateAdd(imgData:pushImgData, imgName: pushImgName, gallery_images: pushGalleryImg, gallery_imageNames: pushGallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params))
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }else  if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddVC2") as? CreateAddVC2 {
                    vc.dataArray = self.objViewModel.dataArray ?? []
                    if popType == .createPost {
                        
                        
                        var galleryImgData = [Data]()
                        for image in selectedImages {
                            if let imgData = image.wxCompress().pngData(){
                                galleryImgData.append(imgData)
                            }
                        }
                        
                        vc.imgData = self.selectedMainImage?.pngData()
                        vc.imgName = self.imgName
                        vc.gallery_images = galleryImgData
                        vc.gallery_imageNames = Array(repeating: "gallery_images[]", count: galleryImgData.count)
                        
                    }else {
                        
                        if delete_item_image_id.count > 0 {
                            params["delete_item_image_id"] = delete_item_image_id.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        
                        if let imgData = selectedMainImage?.wxCompress().pngData(){
                            
                            if self.imgDataMain != imgData {
                                vc.imgData = imgData
                                vc.imgName = self.imgName
                            }
                        }
                        
                       
                        //send only images that is updated by user
                        for ind in 0..<(self.selImgDataArray.count){
                            let data = self.selImgDataArray[ind]
                            var found = false
                            for index in 0..<(self.itemObj?.galleryImages?.count ?? 0){
                                if let obj = self.itemObj?.galleryImages?[index] {
                                    
                                    if obj.imgData == data {
                                        found = true
                                        break
                                    }
                                }
                            }
                            
                            if found == false {
                                vc.gallery_images.append(data)
                                vc.gallery_imageNames.append("gallery_images[]")
                            }
                        }
                        
                    }
                    
                     print(params)
                    vc.params = self.params
                    vc.popType = self.popType
                    vc.itemObj = self.itemObj
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            
        }
        
    }
    
    
    func generateSlug(_ title: String) -> String {
        // Convert to lowercase
        var slug = title.lowercased()
        
        // Replace spaces with dashes
        slug = slug.replacingOccurrences(of: " ", with: "-")
        
        // Remove invalid characters (keep only a-z, 0-9, and dashes)
        slug = slug.replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
        return slug
    }
    
    func downloadImgData(){
        //get the data for main image
        
        loadImageAsync(from: self.itemObj?.image ?? "",isMainImage: true)
        
        for imgUrl in self.itemObj?.galleryImages ?? []{
            
            
            loadImageAsync(from: imgUrl.image ?? "",isMainImage: false)
        }
    }
    
    
     func loadImageAsync(from urlString: String,isMainImage:Bool) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else { return }
            
            DispatchQueue.main.async {
                if isMainImage{
                    self.selectedMainImage = image
                    self.imgDataMain = data
                }else{
                    self.selectedImages.append(image)
                    self.selImgDataArray.append(data)

                }
           
            }
        }.resume()
    }

     func updateData(){
        if popType == .createPost {
           objViewModel = PostAdsViewModel()
            objViewModel.getCustomFieldsListApi(category_ids: category_ids)
            params[AddKeys.all_category_ids.rawValue] = category_ids
            params[AddKeys.category_id.rawValue] = objSubCategory?.id ?? 0
            
            if category_ids.components(separatedBy: ",").count == 1{
                if let catId = Int(category_ids){
                    params[AddKeys.category_id.rawValue] = catId
                }
            }
            params[AddKeys.show_only_to_premium.rawValue] = 0
            let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
            params[AddKeys.name.rawValue] = ""
            params[AddKeys.price.rawValue] = ""
            params[AddKeys.contact.rawValue] = objLoggedInUser.mobile ?? ""
            params[AddKeys.video_link.rawValue] = ""
            params[AddKeys.description.rawValue] = ""
            
        }else{
            objViewModel = PostAdsViewModel()
            objViewModel.dataArray =  self.itemObj?.customFields
            params[AddKeys.all_category_ids.rawValue] = self.itemObj?.allCategoryIDS
            params[AddKeys.category_id.rawValue] = self.itemObj?.categoryID ?? 0
            params[AddKeys.show_only_to_premium.rawValue] = self.itemObj?.showOnlyToPremium ?? 0
            
            let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
            
            strAdTitle = self.itemObj?.name ?? ""
            price = "\(Int(self.itemObj?.price ?? 0.0))"
            phonenumber = objLoggedInUser.mobile ?? ""
            strVideoLink = self.itemObj?.videoLink ?? ""
            strAdDescription = self.itemObj?.description ?? ""
            params["id"] = "\(self.itemObj?.id ?? 0)"
            
        }
    }
}

#Preview {
    CreateAdFirstView()
}



struct ImageCellView:View {
    
    let imgUrl:String
    var body: some View {
        ZStack{
            
            AsyncImage(url: URL(string: imgUrl))
            VStack{
                Button {
                    
                } label: {
                    Image("Cross").frame(width: 20,height: 20)
                }.background(RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground)))

                Spacer()
            }
            
        }.frame(width: 90,height: 90).overlay{
            RoundedRectangle(cornerRadius: 8.0).stroke(Color(.label),lineWidth: 1.0)
            
        }
        
    }
}


import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
     @Binding var selectedImages: [UIImage]
     var maxSelectLimit = 1
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = maxSelectLimit // Max 5 images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No need to update in this case
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            parent.selectedImages.removeAll()

            for result in results.prefix(5) {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}
