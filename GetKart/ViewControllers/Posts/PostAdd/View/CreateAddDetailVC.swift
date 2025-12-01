//
//  CreateAddDetailVC.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit
import SwiftUI
import PhotosUI
import NSFWDetector
import UIKit
import CoreML
import Vision
enum AddKeys: String{
    
    case name
    case slug
    case description
    case category_id
    case price
    case contact
    case video_link
    case all_category_ids
    case custom_fields
    case address
    case latitude
    case longitude
    case country
    case city
    case state
    case show_only_to_premium
    case area

}

var isPostValidate = 0

class CreateAddDetailVC: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    var objCategory: CategoryModel?
    var objSubCategory:Subcategory?
    
    var numberOfPictures = 2
    var strCategoryTitle = ""
    var strSubCategoryTitle = ""
    var category_ids = ""
    var objViewModel:CustomFieldsViewModel?
    var params:Dictionary<String,Any> = [:]
    lazy private var imagePicker = UIImagePickerController()
    var imgData:Data?
    var imgDataEditPost:Data?
    var imgName = "image"
    var gallery_images:Array<Data> = []
    var gallery_imageNames:Array<String> = []
    var delete_item_image_id:String = ""
    var isImgData = false
    private var showErrorMsg = false
    var popType:PopType? = .createPost
    var itemObj:ItemModel?
    var selectedRow = -1
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt

        btnBack.setImageColor(color: .label)

        tblView.register(UINib(nibName: "AlmostThereCell", bundle: nil), forCellReuseIdentifier: "AlmostThereCell")
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        tblView.register(UINib(nibName: "TVCell", bundle: nil), forCellReuseIdentifier: "TVCell")
        tblView.register(UINib(nibName: "PictureAddedCell", bundle: nil), forCellReuseIdentifier: "PictureAddedCell")
        
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = UITableView.automaticDimension
        tblView.separatorColor = .clear
       
        if popType == .createPost {
            objViewModel = CustomFieldsViewModel()
            objViewModel?.delegate = self
             objViewModel?.getCustomFieldsListApi(category_ids: category_ids)

          /*  let idsArray = category_ids
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            if let lastID = idsArray.last {
                print("Last ID: \(lastID)")
                objViewModel?.getCustomFieldsListApi(category_ids: lastID)

            } else {
                print("No IDs found!")
                objViewModel?.getCustomFieldsListApi(category_ids: category_ids)

            }*/
            
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
            objViewModel = CustomFieldsViewModel()
            objViewModel?.dataArray =  self.itemObj?.customFields
            
            params[AddKeys.all_category_ids.rawValue] = self.itemObj?.allCategoryIDS
            params[AddKeys.category_id.rawValue] = self.itemObj?.categoryID ?? 0
            params[AddKeys.show_only_to_premium.rawValue] = self.itemObj?.showOnlyToPremium ?? 0
            
            let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
            
            params[AddKeys.name.rawValue] = self.itemObj?.name ?? ""
            params[AddKeys.price.rawValue] = "\(Int(self.itemObj?.price ?? 0.0))"
            params[AddKeys.contact.rawValue] = objLoggedInUser.mobile ?? ""
            params[AddKeys.video_link.rawValue] = self.itemObj?.videoLink ?? ""
            params[AddKeys.description.rawValue] = self.itemObj?.description ?? ""
            params["id"] = "\(self.itemObj?.id ?? 0)"
            
            
            params[AddKeys.city.rawValue] =  self.itemObj?.city ?? ""
            params[AddKeys.state.rawValue] =  self.itemObj?.state ?? ""
            params[AddKeys.country.rawValue] =  self.itemObj?.country ?? ""
            params[AddKeys.latitude.rawValue] =  self.itemObj?.latitude ?? ""
            params[AddKeys.longitude.rawValue] =  self.itemObj?.longitude ?? ""
            params[AddKeys.address.rawValue] =  self.itemObj?.address ?? ""

            
            
            self.downloadImgData()
        }
    }
    
    
    func downloadImgData(){
        //get the data for main image
        if let url = URL(string: self.itemObj?.image ?? "") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
              
                guard let data = data, error == nil else { return }
                self.imgData = data
                self.imgDataEditPost = data
                
                DispatchQueue.main.async(execute: {
                
                let indexPath = IndexPath(row: 3, section: 0)
                if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                        
                    cell.btnAddPicture.isHidden = true
                    cell.clnCollectionView.isHidden = false
                        
                        if cell.arrImagesData.count == 0 {
                            var arr:Array<Data> = []
                            arr.append(self.imgData ?? Data())
                            cell.arrImagesData = arr
                            cell.clnCollectionView!.insertItems(at: [IndexPath(item: 0, section: 0)])
                        }else {
                            cell.arrImagesData.removeAll()
                            var arr:Array<Data> = []
                            arr.append(self.imgData ?? Data())
                            cell.arrImagesData = arr
                        }
                    
                        cell.clnCollectionView.performBatchUpdates({
                            cell.clnCollectionView.reloadData()
                            cell.clnCollectionView.collectionViewLayout.invalidateLayout()
                        }) { _ in
                            // Code to execute after reloadData and layout updates
                            self.tblView.beginUpdates()
                            self.tblView.endUpdates()
                            if self.itemObj?.galleryImages?.count ?? 0 > 0 {
                                self.downloadGalleryImages(index: 0)
                            }
                        }
                }
                })
            }
            
            task.resume()
        }
  }
    
    func downloadGalleryImages(index:Int) {
        //get the data for gallery images
        if index < self.itemObj?.galleryImages?.count ?? 0 {
            if let obj = self.itemObj?.galleryImages?[index] {
                if let url = URL(string: obj.image ?? "") {
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        self.gallery_images.append(data)
                        self.gallery_imageNames.append("gallery_images[]")
                        self.itemObj?.galleryImages?[index].imgData = data
                        
                        
                        
                        DispatchQueue.main.async(execute: {
                            let indexPath = IndexPath(row: 4, section: 0)
                            if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                                
                                cell.btnAddPicture.isHidden = true
                                cell.clnCollectionView.isHidden = false
                                
                                cell.arrImagesData = self.gallery_images
                                cell.clnCollectionView!.insertItems(at: [IndexPath(item: self.gallery_images.count - 1, section: 0)])
                                
                                cell.clnCollectionView.performBatchUpdates({
                                    cell.clnCollectionView.reloadData()
                                    cell.clnCollectionView.collectionViewLayout.invalidateLayout()
                                }) { _ in
                                    // Code to execute after reloadData and layout updates
                                    self.tblView.beginUpdates()
                                    self.tblView.endUpdates()
                                }
                                
                                let index1 = index + 1
                                if index1 < (self.itemObj?.galleryImages?.count ?? 0) {
                                    
                                    self.downloadGalleryImages(index:index1)
                                }
                            }
                        })
                        
                    }
                    task.resume()
                }
            }
        }
    }
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
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
    
    func pushToValidateMobileNumber(){
      //  if (params[AddKeys.contact.rawValue] as? String ?? "").count > 0 { return}
        let destVc = UIHostingController(rootView: MobileNumberView(navigationController: self.navigationController,onDismissUpdatedMobile: { strMob in
            self.params[AddKeys.contact.rawValue]  = strMob
            self.tblView.reloadData()
        }))
        self.navigationController?.pushViewController(destVc, animated: true)
    }
    
    @IBAction func nextButtonAction() {
        
        
        
        params[AddKeys.name.rawValue] = (params[AddKeys.name.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        params[AddKeys.price.rawValue] = (params[AddKeys.price.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (params[AddKeys.contact.rawValue] as? String  ?? "").count == 0{
            params.removeValue(forKey: AddKeys.contact.rawValue)
        }else{
            params[AddKeys.contact.rawValue] = (params[AddKeys.contact.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        params[AddKeys.video_link.rawValue] = (params[AddKeys.video_link.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        params[AddKeys.description.rawValue] = (params[AddKeys.description.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                
        var scrollIndex = -1
        
        if  (params[AddKeys.name.rawValue] as? String  ?? "").trim().count == 0 || (params[AddKeys.name.rawValue] as? String  ?? "").trim().count < 3  {
            
            showErrorMsg = true
            scrollIndex = 0
            
        }
//        else if !(params[AddKeys.name.rawValue] as? String  ?? "").isValidName(){
//            showErrorMsg = true
//            scrollIndex = 0
//            
//        }
        else if  (params[AddKeys.description.rawValue] as? String  ?? "").count == 0  || (params[AddKeys.description.rawValue] as? String  ?? "").count > 4000{
            
            showErrorMsg = true
            scrollIndex = 1
            
        }else if  imgData == nil{
            
            showErrorMsg = true
            scrollIndex = 2
            
        }else if  (params[AddKeys.price.rawValue] as? String  ?? "").count == 0  || (params[AddKeys.price.rawValue] as? String ?? "0").hasPrefix("0"){
            
            showErrorMsg = true
            scrollIndex = 4
       }else if let price =  Int(params[AddKeys.price.rawValue] as? String  ?? "0"), (price < 1 && price > 9) {
            
            showErrorMsg = true
            scrollIndex = 4
            
            //        }else if  (params[AddKeys.contact.rawValue] as? String  ?? "").count == 0 {
            //
            //            showErrorMsg = true
            
        } else {
            
            
            if popType == .createPost {
                
            }else{
                if itemObj?.status != "approved"{
                    isPostValidate = 0
                }
            }

            
            showErrorMsg = false
            self.params["slug"] = self.generateSlug(self.params[AddKeys.name.rawValue] as? String ?? "")
           
            if self.objViewModel?.dataArray?.count == 0 {
                //If no any custom field
//                var vc = ConfirmLocationHostingController(rootView: ConfirmLocationCreateAdd(imgData: self.imgData, imgName: self.imgName, gallery_images: self.gallery_images, gallery_imageNames: self.gallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params))
//                
                
                if popType == .createPost {
                  /*  let vc = ConfirmLocationHostingController(rootView: ConfirmLocationCreateAdd(imgData: self.imgData, imgName: self.imgName, gallery_images: self.gallery_images, gallery_imageNames: self.gallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params))
                    self.navigationController?.pushViewController(vc, animated: true)*/
                    
                    
                    
                    if let vc = StoryBoard.postAdd.instantiateViewController(withIdentifier: "PostAdFinalVC") as? PostAdFinalVC{
                        
//                        vc.latitude = itemObj?.latitude ?? 0.0
//                        vc.longitude = itemObj?.longitude ?? 0.0
                        vc.imgData = self.imgData
                        vc.imgName = self.imgName
                        vc.gallery_images = self.gallery_images
                        vc.gallery_imageNames = self.gallery_imageNames
                        vc.popType = self.popType
                        vc.params = self.params
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }

                }else{
                    
                    var pushImgData:Data? // = self.imgData
                    var pushImgName = "" // self.imgName
                    var pushGalleryImg : Array<Data> = []
                    var pushGallery_imageNames : Array<String> = []
                    
                    if delete_item_image_id.count > 0 {
                        params["delete_item_image_id"] = delete_item_image_id.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    if self.imgDataEditPost != imgData {
                        pushImgData = self.imgData
                        pushImgName = self.imgName
                    }
                    
                    //send only images that is updated by user
                    for ind in 0..<self.gallery_images.count{
                        let data = self.gallery_images[ind]
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
                            pushGallery_imageNames.append(self.gallery_imageNames[ind])
                        }
                    }
                    
                   /* let vc = ConfirmLocationHostingController(rootView: ConfirmLocationCreateAdd(latitiude:itemObj?.latitude ?? 0.0, longitude:itemObj?.longitude ?? 0.0,imgData:pushImgData, imgName: pushImgName, gallery_images: pushGalleryImg, gallery_imageNames: pushGallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params))
                    
                    self.navigationController?.pushViewController(vc, animated: true)*/
                    
                    if let vc = StoryBoard.postAdd.instantiateViewController(withIdentifier: "PostAdFinalVC") as? PostAdFinalVC{
                        
                        vc.latitude = itemObj?.latitude ?? 0.0
                        vc.longitude = itemObj?.longitude ?? 0.0
                        vc.imgData = pushImgData
                        vc.imgName = pushImgName
                        vc.gallery_images = pushGalleryImg
                        vc.gallery_imageNames =  pushGallery_imageNames
                        vc.popType = self.popType
                        vc.params = self.params
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            }else  if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddVC2") as? CreateAddVC2 {
                vc.dataArray = self.objViewModel?.dataArray ?? []
                if popType == .createPost {
                    
                    vc.imgData = self.imgData
                    vc.imgName = self.imgName
                    vc.gallery_images = self.gallery_images
                    vc.gallery_imageNames = self.gallery_imageNames
                    
                }else {
                    
                    if delete_item_image_id.count > 0 {
                        params["delete_item_image_id"] = delete_item_image_id.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    if self.imgDataEditPost != imgData {
                        vc.imgData = self.imgData
                        vc.imgName = self.imgName
                    }
                    
                    //send only images that is updated by user
                    for ind in 0..<self.gallery_images.count{
                        let data = self.gallery_images[ind]
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
                            vc.gallery_imageNames.append(self.gallery_imageNames[ind])
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
        
        tblView.reloadData()
        
        if scrollIndex >= 0{
            self.tblView.scrollToRow(at: IndexPath(row: scrollIndex, section: 0), at: .top, animated: true)
        }
    }
}

extension CreateAddDetailVC:RefreshScreen {
    func refreshScreen() {
        // print(self.objViewModel?.dataArray)
    }
}

extension CreateAddDetailVC:UITableViewDelegate, UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 + numberOfPictures
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
      
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlmostThereCell") as! AlmostThereCell
           // cell.lblCategory.text = strCategoryTitle
           
            
            if strSubCategoryTitle.count > 0 {
                cell.setAtrributtedTextToLabel(firstText: strCategoryTitle, secondText: "> \(strSubCategoryTitle)")
               // cell.lblSubCategory.text = "> \(strSubCategoryTitle)"
            }else{
                cell.setAtrributtedTextToLabel(firstText: strCategoryTitle, secondText: "")
            }
            
            
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Add Title"
            cell.iconBgView.isHidden = true

            cell.txtField.keyboardType = .default
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            cell.txtField.placeholder = ""
            cell.txtField.maxLength = 60
            cell.lblCurSymbol.isHidden =  true
            cell.txtField.leftPadding = 10
            cell.showCurrencySymbol = false
            cell.lblErrorMsg.isHidden = true
            cell.txtField.text = params[AddKeys.name.rawValue] as? String ?? ""
            cell.txtField.autocapitalizationType = .sentences
            
            if showErrorMsg == true  && (self.selectedRow != indexPath.row) {
                if (params[AddKeys.name.rawValue] as? String ?? "") == "" {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = "Field must not be empty."
                }
                else if (params[AddKeys.name.rawValue] as? String  ?? "").count < 3 {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = "Please enter valid Ad Title"
                }else{
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
            }
            return cell
     
        }else if indexPath.row == 2 {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "TVCell") as! TVCell
            cell.lblTitle.text = "Description"
            cell.textViewDoneDelegate = self
            cell.tvTextView.tag = indexPath.row
            cell.tvTextView.text = params[AddKeys.description.rawValue] as? String ?? ""
            cell.lblErrorMsg.text = "Please enter a description under 4000 characters."
            if showErrorMsg == true && (self.selectedRow != indexPath.row) {
                if (params[AddKeys.description.rawValue] as? String ?? "") == "" {
                    cell.lblErrorMsg.isHidden = false
                    cell.tvTextView.layer.borderColor = UIColor.red.cgColor
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.tvTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.tvTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
            }
            return cell
        }else if indexPath.row == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureAddedCell") as! PictureAddedCell
            cell.lblTitle.text = "Main Picture(Max 3MB)"
            
            var arr:Array<Data> = []
            if imgData != nil {
                cell.btnAddPicture.isHidden = true
                cell.clnCollectionView.isHidden = false
                arr.append(imgData ?? Data())
            }else {
                cell.btnAddPicture.isHidden = false
                cell.clnCollectionView.isHidden = true
            }
            cell.btnAddPicture.setTitle("Add Main Picture", for: .normal)
            cell.btnAddPicture.tag = indexPath.row
            cell.btnAddPicture.addTarget(self, action: #selector(addPictureBtnAction(_:)), for: .touchDown)
            
            cell.rowValue = indexPath.row
            cell.pictureAddDelegate = self
            cell.configure(with: arr)
            if showErrorMsg == true {
                if imgData == nil {
                    cell.lblErrorMsg.isHidden = false
                    cell.lblErrorMsg.text = "Item main image is required."
                    cell.btnAddPicture.borderColor = UIColor.red
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.btnAddPicture.borderColor  = UIColor.lightGray
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.btnAddPicture.borderColor  = UIColor.lightGray
            }
            
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 4 {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureAddedCell") as! PictureAddedCell
            cell.lblTitle.text = "Other Picture(Max 5 images)"
             if gallery_images.count == 0 {
                cell.btnAddPicture.isHidden = false
                cell.clnCollectionView.isHidden = true
            }else {
                cell.btnAddPicture.isHidden = true
                cell.clnCollectionView.isHidden = false
            }
            cell.btnAddPicture.setTitle("Add Other Pictures", for: .normal)
            cell.btnAddPicture.tag = indexPath.row
            cell.btnAddPicture.addTarget(self, action: #selector(addPictureBtnAction(_:)), for: .touchDown)
            cell.rowValue = indexPath.row
            cell.pictureAddDelegate = self

            cell.configure(with: gallery_images)
            
            /*if showErrorMsg == true {
                if gallery_images.count == 0 {
                    cell.lblErrorMsg.isHidden = false
                    cell.btnAddPicture.borderColor = UIColor.red
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.btnAddPicture.borderColor  = UIColor.lightGray
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.btnAddPicture.borderColor  = UIColor.lightGray
            }
            */
            cell.selectionStyle = .none
            return cell
            
        }else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.iconBgView.isHidden = true

            cell.lblTitle.text = "Price"
            
            cell.txtField.placeholder = "00"
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            cell.showCurrencySymbol = true
            cell.txtField.maxLength = 9
            cell.lblErrorMsg.isHidden = true
            cell.txtField.text = (params[AddKeys.price.rawValue] as? String ?? "")
            cell.lblCurSymbol.text = Local.shared.currencySymbol
            if (params[AddKeys.price.rawValue] as? String ?? "").count > 1{
                cell.lblCurSymbol.isHidden =  false
                cell.txtField.leftPadding = 25
            }else{
                cell.lblCurSymbol.isHidden =  true
                cell.txtField.leftPadding = 10
            }
            
             if showErrorMsg == true && (self.selectedRow != indexPath.row) {
                 if let price = Int(params[AddKeys.price.rawValue] as? String ?? "0"),price < 1{
                    cell.lblErrorMsg.text = "Price must be greater than 0"
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    
                 }else if (params[AddKeys.price.rawValue] as? String ?? "0").hasPrefix("0"){
                    cell.lblErrorMsg.text = "Price must be valid"
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    
                }else if (params[AddKeys.price.rawValue] as? String ?? "") == "" {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = "Field must not be empty"

                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
            }
            
            return cell
        }else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.iconBgView.isHidden = true

            cell.lblTitle.text = "Phone Number(optional)"
            cell.txtField.placeholder = "Enter Phone Number"
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = false
            cell.textFieldDoneDelegate = self
            cell.txtField.maxLength = 11
            cell.lblErrorMsg.isHidden = true
            cell.lblCurSymbol.isHidden =  true
            cell.txtField.leftPadding = 10
            cell.showCurrencySymbol = false
            
           // cell.txtField.isUserInteractionEnabled = (params[AddKeys.contact.rawValue] as? String ?? "").count > 0 ? false : true

            cell.btnOptionBig.addTarget(self, action: #selector(moileVerifyAction), for: .touchUpInside)
            cell.txtField.text = params[AddKeys.contact.rawValue] as? String ?? ""
            
            /*if showErrorMsg == true && (self.selectedRow != indexPath.row){
                if (params[AddKeys.contact.rawValue] as? String ?? "") == "" {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else {*/
               // cell.lblErrorMsg.isHidden = true
                //cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
           // }
            
           // if (params[AddKeys.contact.rawValue] as? String ?? "").count == 0{
                cell.lblErrorMsg.text = "Verified mobiles build trust & get faster responses ✓"
                cell.lblErrorMsg.isHidden = false
                cell.lblErrorMsg.textColor = UIColor.lightGray
            //}
            return cell
        }else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.iconBgView.isHidden = true

            cell.lblTitle.text = "Video Link(optional)"
            cell.txtField.placeholder = "http://example.com/video.mp4"
            cell.lblErrorMsg.isHidden = true
            cell.txtField.keyboardType = .default
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            cell.lblErrorMsg.isHidden = true
            cell.lblCurSymbol.isHidden =  true
            cell.txtField.leftPadding = 10
            cell.showCurrencySymbol = false
            cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor

            cell.txtField.text = params[AddKeys.video_link.rawValue] as? String ?? ""
           /* if showErrorMsg == true {
                if (params[AddKeys.video_link.rawValue] as? String ?? "") == "" {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
            }
            */
            
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func moileVerifyAction(){
        pushToValidateMobileNumber()
    }
}


extension CreateAddDetailVC: TextFieldDoneDelegate, TextViewDoneDelegate{
    //MARK: UITextField Delegate

    func textFieldEditingDone(selectedRow:Int, strText:String) {
        self.selectedRow = -1
       // print(selectedRow, strText)
       // print( AddKeys.name)
        if selectedRow == 1 {
            params[AddKeys.name.rawValue] = strText
        }else if selectedRow == 5 {
            params[AddKeys.price.rawValue] = strText
        }else if selectedRow == 6 {
            params[AddKeys.contact.rawValue] = strText
        }else if selectedRow == 7 {
            params[AddKeys.video_link.rawValue] = strText
        }
        self.tblView.reloadData()

    }
    
    
    func textFieldEditingBegin(selectedRow:Int, strText:String){
        self.selectedRow = selectedRow
        if selectedRow == 6{
            self.view.endEditing(true)
            self.pushToValidateMobileNumber()
        }else  if selectedRow == 7{
          
        }else{
            if let cell = tblView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? TFCell{
                tblView.beginUpdates()
                cell.lblErrorMsg.isHidden = true
                cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                tblView.endUpdates()
            }
        }
    }
    
    //MARK: UITextview Delegate
    func textViewEditingDone(selectedRow:Int, strText:String) {
        self.selectedRow = -1

        if selectedRow == 2 {
            params[AddKeys.description.rawValue] = strText
        }
        self.tblView.reloadData()

    }
    
    func textViewEditingBegin(selectedRow:Int, strText:String)
    {
        self.selectedRow = selectedRow
        
        if let cell = tblView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? TVCell{
            tblView.beginUpdates()
            cell.lblErrorMsg.isHidden = true
            cell.tvTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
            tblView.endUpdates()
        }
    }
}

//MARK: PHPickerDelegate
extension CreateAddDetailVC:  PHPickerViewControllerDelegate{
    
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        
        if isImgData{
            configuration.selectionLimit = 1

        }else{
            if self.gallery_images.count == 5{
                configuration.selectionLimit = 0

            }else{
                configuration.selectionLimit = 5 - self.gallery_images.count // 0 = unlimited selection
            }
        }
       
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }

    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let pickedImage = object as? UIImage {
                        print("Selected image: \(pickedImage)")
                        self.checkNudityOfiMages(pickedImage: pickedImage)

                        if self.isImgData{
                            DispatchQueue.main.async {

                            self.imgData = pickedImage.wxCompress().jpegData(compressionQuality: 1.0)
                            self.imgName = "image"
                            let indexPath = IndexPath(row: 3, section: 0)
                            if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                                
                                cell.btnAddPicture.isHidden = true
                                cell.clnCollectionView.isHidden = false
                                
                                if cell.arrImagesData.count == 0 {
                                    var arr:Array<Data> = []
                                    arr.append(self.imgData ?? Data())
                                    cell.arrImagesData = arr
                                    cell.clnCollectionView!.insertItems(at: [IndexPath(item: 0, section: 0)])
                                }else {
                                    cell.arrImagesData.removeAll()
                                    var arr:Array<Data> = []
                                    arr.append(self.imgData ?? Data())
                                    cell.arrImagesData = arr
                                }
                                
                                cell.lblErrorMsg.isHidden = true
                                
                                cell.reloadCollection()
                                self.tblView.beginUpdates()
                                self.tblView.endUpdates()
                            }
                        }
                         }else{
                            DispatchQueue.main.async {
                                
                                self.gallery_images.append(pickedImage.wxCompress().jpegData(compressionQuality: 0.0) ?? Data())
                                self.gallery_imageNames.append("gallery_images[]")
                               
                                let indexPath = IndexPath(row: 4, section: 0)
                                if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                                    
                                    cell.btnAddPicture.isHidden = true
                                    cell.clnCollectionView.isHidden = false
                                    cell.lblErrorMsg.isHidden = true

                                    cell.arrImagesData = self.gallery_images
                                    cell.clnCollectionView?.insertItems(at: [IndexPath(item: self.gallery_images.count - 1, section: 0)])
                                    cell.reloadCollection()
                                    self.tblView.beginUpdates()
                                    self.tblView.endUpdates()
                                    
                                }
                            }

                        }

                    }
                }
            }
        }
    }
}


// MARK: ImagePicker Delegate
extension CreateAddDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
  
  

    func detectNudity(in image: UIImage, completion: @escaping (Bool, VNConfidence?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(false, nil)
            return
        }

        do {
            let configuration = MLModelConfiguration()
            let coreMLModel = try OpenNSFW(configuration: configuration).model
            let vnModel = try VNCoreMLModel(for: coreMLModel)

            let request = VNCoreMLRequest(model: vnModel) { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    completion(false, nil)
                    return
                }

                let explicitKeywords = ["nsfw", "nudity", "porn", "sexual", "explicit"]
                var maxConfidence: VNConfidence = 0.0
                var isExplicit = false

                for result in results {
                    let label = result.identifier.lowercased()
                    if explicitKeywords.contains(where: { label.contains($0) }) {
                        isExplicit = true
                        maxConfidence = max(maxConfidence, result.confidence)
                    }
                }

                completion(isExplicit, maxConfidence)
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform VN request: \(error)")
                    completion(false, nil)
                }
            }

        } catch {
            print("Failed to load Core ML model: \(error)")
            completion(false, nil)
        }
    }



    
    func checkNudityOfiMages(pickedImage: UIImage) {
        
        if Float(Local.shared.iosNudityThreshold) > 0 {
            
            detectNudity(in: pickedImage) { isExplicit, confidence in
                if isExplicit {
                    print("Nudity detected with confidence: \(confidence!)")
                    DispatchQueue.main.async {
                        
                        if (confidence ?? 0) > Float(Local.shared.iosNudityThreshold) {
                            isPostValidate = 0
                            /* AlertView.sharedManager.displayMessageWithAlert(
                             title: "!Alert",
                             msg: "Uploading or sharing any form of vulgar or offensive content on this platform is strictly prohibited."
                             )*/
                        }else{
                            isPostValidate = 1
                        }
                    }
                } else {
                    isPostValidate = 1
                    print("Image is safe")
                }
            }
        }

        
        return
//        pickedImage.checkNSFW() { result, confidence in
//       
//            print(" confidence == \(confidence)")
//            DispatchQueue.main.async {
//                switch result {
//                case .sfw:
//                       // isPostValidate = 1
//
//                case .nsfw:
//                    if confidence > 0.5 {
//                        isPostValidate = 0
//                        AlertView.sharedManager.displayMessageWithAlert(
//                            title: "!Alert",
//                            msg: "Uploading or sharing any form of vulgar or offensive content on this platform is strictly prohibited."
//                        )
//                    } else {
//                       // isPostValidate = 1
//                    }
//                case .unknown:
//                    isPostValidate = 0
//                }
//            }
//        }

//        NSFWDetector.shared.check(image: pickedImage) { result in
//            switch result {
//            case let .success(nsfwConfidence: confidence):
//
//                print(" confidence == \(confidence)")
//                DispatchQueue.main.async {   // <-- FIX IS HERE
//                    if confidence > 0.05 {
//                        isPostValidate = 0
//                        AlertView.sharedManager.displayMessageWithAlert(
//                            title: "!Alert",
//                            msg: "Uploading or sharing any form of vulgar or offensive content on this platform is strictly prohibited."
//                        )
//                    } else {
//                        isPostValidate = 1
//                    }
//                }
//
//            default:
//                break
//            }
//        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        if let pickedImage = info[.originalImage] as? UIImage {
            
            checkNudityOfiMages(pickedImage: pickedImage)
           

            if isImgData == true {
                
                imgData = pickedImage.wxCompress().jpegData(compressionQuality: 1.0)
                imgName = "image"
                let indexPath = IndexPath(row: 3, section: 0)
                if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                        
                        
                    cell.btnAddPicture.isHidden = true
                    cell.clnCollectionView.isHidden = false
                        
                        if cell.arrImagesData.count == 0 {
                            var arr:Array<Data> = []
                            arr.append(imgData ?? Data())
                            cell.arrImagesData = arr
                            cell.clnCollectionView!.insertItems(at: [IndexPath(item: 0, section: 0)])
                        }else {
                            cell.arrImagesData.removeAll()
                            var arr:Array<Data> = []
                            arr.append(imgData ?? Data())
                            cell.arrImagesData = arr
                        }
                    
                    cell.lblErrorMsg.isHidden = true
                    
                    cell.reloadCollection()
                    self.tblView.beginUpdates()
                    self.tblView.endUpdates()
                }
            }else {
                gallery_images.append(pickedImage.wxCompress().jpegData(compressionQuality: 0.0) ?? Data())
                gallery_imageNames.append("gallery_images[]")
               
                
                let indexPath = IndexPath(row: 4, section: 0)
                if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                    
                    cell.btnAddPicture.isHidden = true
                    cell.clnCollectionView.isHidden = false
                    cell.lblErrorMsg.isHidden = true

                    cell.arrImagesData = self.gallery_images
                    cell.clnCollectionView!.insertItems(at: [IndexPath(item: gallery_images.count - 1, section: 0)])
              
                    cell.reloadCollection()
                    self.tblView.beginUpdates()
                    self.tblView.endUpdates()
                    
                }
            }
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Handle the user canceling the image picker, if needed.
        dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        
        
    }
    
    @objc func addPictureBtnAction(_ sender:UIButtonX){
        if sender.tag == 3 {
            isImgData = true
        }else {
            isImgData = false
        }
        showImagePickerOptions(tag: sender.tag)
    }
    
    
    @objc func showImagePickerOptions(tag:Int) {
        let actionSheet = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openImagePicker(sourceType: .camera, tag: tag)
            }))
        }

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openImagePicker(sourceType: .photoLibrary, tag: tag)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // For iPad: prevent crash
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(actionSheet, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType,tag:Int) {
        
        if sourceType == .camera{
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
             imagePicker.delegate = self
             imagePicker.sourceType = sourceType
             imagePicker.navigationBar.tag = tag
             imagePicker.allowsEditing = false
             self.present(imagePicker, animated: true)
        }else{
            presentPhotoPicker()
        }

       /* imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.navigationBar.tag = tag
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)*/

    }
}


extension CreateAddDetailVC: PictureAddedDelegate {
    
    func addPictureAction(row:Int) {
        
        if row == 3 {
            isImgData = true
        }else {
            if gallery_images.count < 5 {
                isImgData = false
            }else {
                if gallery_images.count == 5 {
                    AlertView.sharedManager.showToast(message: "Max 5 images are allowed to upload.")
                    return
                }
            }
        }
        showImagePickerOptions(tag: row)
    }
    
    
    func removePictureAction(row:Int, col:Int) {
        let indexPath = IndexPath(row: row, section: 0)
        if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
            cell.clnCollectionView.performBatchUpdates({
                cell.arrImagesData.remove(at: col)
                if row == 3 {
                    self.imgData = nil
                    self.imgName = ""
                    
                }else {
                    if self.popType == .editPost {
                        let data = gallery_images[col]
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
                    
                    if (self.itemObj?.galleryImages?.count ?? 0) > col{
                        
                        self.itemObj?.galleryImages?.remove(at: col)
                    }
                    
                    gallery_images.remove(at: col)
                    gallery_imageNames.remove(at: col)
                    cell.arrImagesData = gallery_images
                }
                print("cell.arrImagesData.count : ", cell.arrImagesData.count)
                cell.clnCollectionView.deleteItems(at: [IndexPath(item: col, section: 0)])
                cell.clnCollectionView.reloadData()
                cell.clnCollectionView.collectionViewLayout.invalidateLayout()
                
            }) { _ in
                // Code to execute after reloadData and layout updates
                cell.clnCollectionView.reloadItems(at: cell.clnCollectionView.indexPathsForVisibleItems)
                self.tblView.reloadData()
            }
        }
    }
}


extension String{
    
    func formatNumberWithComma() -> String {
        guard let number = Int(self) else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}








extension UIImage {
    var cgImageSafe: CGImage? {
        if let cg = self.cgImage { return cg }
        let ci = CIImage(image: self)
        let context = CIContext()
        return ci.flatMap { context.createCGImage($0, from: $0.extent) }
    }
}
