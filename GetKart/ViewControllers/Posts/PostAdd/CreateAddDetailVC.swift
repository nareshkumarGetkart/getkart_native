//
//  CreateAddDetailVC.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit

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
}
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
    lazy var imagePicker = UIImagePickerController()
    
    var imgData:Data?
    var imgName = ""
    var gallery_images:Array<Data> = []
    var gallery_imageNames:Array<String> = []
    var isImgData = false
    var showErrorMsg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "AlmostThereCell", bundle: nil), forCellReuseIdentifier: "AlmostThereCell")
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        tblView.register(UINib(nibName: "TVCell", bundle: nil), forCellReuseIdentifier: "TVCell")
        tblView.register(UINib(nibName: "AddPictureCell", bundle: nil), forCellReuseIdentifier: "AddPictureCell")
        tblView.register(UINib(nibName: "PictureAddedCell", bundle: nil), forCellReuseIdentifier: "PictureAddedCell")
        
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = UITableView.automaticDimension
        tblView.separatorColor = .clear
        
        objViewModel = CustomFieldsViewModel()
        objViewModel?.delegate = self
        objViewModel?.getCustomFieldsListApi(category_ids: category_ids)
        
        params[AddKeys.all_category_ids.rawValue] = category_ids
        params[AddKeys.category_id.rawValue] = objSubCategory?.id ?? 0
        params[AddKeys.show_only_to_premium.rawValue] = 0
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        
        params[AddKeys.name.rawValue] = ""
        params[AddKeys.price.rawValue] = ""
        params[AddKeys.contact.rawValue] = objLoggedInUser.mobile ?? ""
        params[AddKeys.video_link.rawValue] = ""
        params[AddKeys.description.rawValue] = ""
    }
    
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
    
    
    
    @IBAction func nextButtonAction() {
        
        params[AddKeys.name.rawValue] = (params[AddKeys.name.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        params[AddKeys.price.rawValue] = (params[AddKeys.price.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        params[AddKeys.contact.rawValue] = (params[AddKeys.contact.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        params[AddKeys.video_link.rawValue] = (params[AddKeys.video_link.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        params[AddKeys.description.rawValue] = (params[AddKeys.description.rawValue] as? String  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        print(params)
        
        if  (params[AddKeys.name.rawValue] as? String  ?? "").count == 0 {
            /*let alert = UIAlertController(title: "", message: "Title can not be left blank.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
             */
            showErrorMsg = true
         
        }  else if  (params[AddKeys.description.rawValue] as? String  ?? "").count == 0 {
//            let alert = UIAlertController(title: "", message: "Description can not be left blank.", preferredStyle: .alert)
//            
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
            showErrorMsg = true
         
        }else if  imgData == nil{
            let alert = UIAlertController(title: "", message: "Main image can not be left blank.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            showErrorMsg = true
         
        }else if  (params[AddKeys.price.rawValue] as? String  ?? "").count == 0 {
            let alert = UIAlertController(title: "", message: "Price can not be left blank.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            showErrorMsg = true
         
        }else if  (params[AddKeys.contact.rawValue] as? String  ?? "").count == 0 {
//            let alert = UIAlertController(title: "", message: "Contact can not be left blank.", preferredStyle: .alert)
//            
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
            showErrorMsg = true
         
        } else {
            showErrorMsg = false
            self.params["slug"] = self.generateSlug(self.params[AddKeys.name.rawValue] as? String ?? "")
            if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddVC2") as? CreateAddVC2 {
                vc.dataArray = self.objViewModel?.dataArray ?? []
                vc.params = self.params
                vc.imgData = self.imgData
                vc.imgName = self.imgName
                vc.gallery_images = self.gallery_images
                vc.gallery_imageNames = self.gallery_imageNames
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
            tblView.reloadData()
        
    }
    
}

extension CreateAddDetailVC:RefreshScreen {
    func refreshScreen() {
        print(self.objViewModel?.dataArray)
    }
}

extension CreateAddDetailVC:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
            cell.lblCategory.text = strCategoryTitle
            cell.lblSubCategory.text = "> \(strSubCategoryTitle)"
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Add Title"
            
            cell.txtField.keyboardType = .default
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            cell.txtField.text = params[AddKeys.name.rawValue] as? String ?? ""
            if showErrorMsg == true {
                if (params[AddKeys.name.rawValue] as? String ?? "") == "" {
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
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TVCell") as! TVCell
            cell.lblTitle.text = "Description"
            cell.textViewDoneDelegate = self
            cell.tvTextView.tag = indexPath.row
            cell.tvTextView.text = params[AddKeys.description.rawValue] as? String ?? ""
            if showErrorMsg == true {
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
            
            cell.arrImagesData = arr
            cell.rowValue = indexPath.row
            cell.pictureAddDelegate = self
            cell.clnCollectionView.performBatchUpdates({
                cell.clnCollectionView.reloadData()
                //cell.clnCollectionView.collectionViewLayout.invalidateLayout()
            }) { _ in
                // Code to execute after reloadData and layout updates
                self.tblView.beginUpdates()
                self.tblView.endUpdates()
            }
            
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 4 {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureAddedCell") as! PictureAddedCell
            cell.lblTitle.text = "Other Picture(Max 5 images)"
            
            cell.arrImagesData = gallery_images
            
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
            
            cell.clnCollectionView.performBatchUpdates({
                cell.clnCollectionView.reloadData()
                cell.clnCollectionView.collectionViewLayout.invalidateLayout()
            }) { _ in
                // Code to execute after reloadData and layout updates
                self.tblView.beginUpdates()
                self.tblView.endUpdates()
            }
            cell.selectionStyle = .none
            return cell
            
        }else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Price"
            cell.txtField.placeholder = "Add Price Here"
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            
            cell.txtField.text = params[AddKeys.price.rawValue] as? String ?? ""
            if showErrorMsg == true {
                if (params[AddKeys.price.rawValue] as? String ?? "") == "" {
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
            
            return cell
        }else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Phone Number"
            cell.txtField.placeholder = "Enter Phone Number"
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            cell.txtField.text = params[AddKeys.contact.rawValue] as? String ?? ""
            if showErrorMsg == true {
                if (params[AddKeys.contact.rawValue] as? String ?? "") == "" {
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
            return cell
        }else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Video Link"
            cell.txtField.placeholder = "http://example.com/video.mp4"
            
            cell.txtField.keyboardType = .default
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            cell.txtField.text = params[AddKeys.video_link.rawValue] as? String ?? ""
            if showErrorMsg == true {
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
            
            return cell
        }
        return UITableViewCell()
    }
    
    
}

extension CreateAddDetailVC: TextFieldDoneDelegate, TextViewDoneDelegate{
    
    func textFieldEditingDone(selectedRow:Int, strText:String) {
        print(selectedRow, strText)
        print( AddKeys.name)
        if selectedRow == 1 {
            params[AddKeys.name.rawValue] = strText
        }else if selectedRow == 5 {
            params[AddKeys.price.rawValue] = strText
        }else if selectedRow == 6 {
            params[AddKeys.contact.rawValue] = strText
        }else if selectedRow == 7 {
            params[AddKeys.video_link.rawValue] = strText
        }
        
    }
    func textViewEditingDone(selectedRow:Int, strText:String) {
        if selectedRow == 2 {
            params[AddKeys.description.rawValue] = strText
        }
    }
}


// MARK: ImagePicker Delegate
extension CreateAddDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if isImgData == true {
                
                imgData = pickedImage.jpegData(compressionQuality: 0.0)
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
                    
                        cell.clnCollectionView.performBatchUpdates({
                            cell.clnCollectionView.reloadData()
                            cell.clnCollectionView.collectionViewLayout.invalidateLayout()
                        }) { _ in
                            // Code to execute after reloadData and layout updates
                            self.tblView.beginUpdates()
                            self.tblView.endUpdates()
                        }
                }
            }else {
                gallery_images.append(pickedImage.jpegData(compressionQuality: 0.0) ?? Data())
                gallery_imageNames.append("gallery_images[]")
                
                let indexPath = IndexPath(row: 4, section: 0)
                if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                    
                    cell.btnAddPicture.isHidden = true
                    cell.clnCollectionView.isHidden = false
                    
                    cell.arrImagesData = self.gallery_images
                    cell.clnCollectionView!.insertItems(at: [IndexPath(item: gallery_images.count - 1, section: 0)])
                    
                    cell.clnCollectionView.performBatchUpdates({
                        cell.clnCollectionView.reloadData()
                        cell.clnCollectionView.collectionViewLayout.invalidateLayout()
                    }) { _ in
                        // Code to execute after reloadData and layout updates
                        self.tblView.beginUpdates()
                        self.tblView.endUpdates()
                    }
                    
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
        
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    
    
}

extension CreateAddDetailVC: PictureAddedDelegate {
    func addPictureAction(row:Int) {
        if row == 3 {
            isImgData = true
        }else {
            isImgData = false
        }
        
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    func removePictureAction(row:Int, col:Int) {
        
            if row == 3 {
                self.imgData = nil
                self.imgName = ""
            }else {
                gallery_images.remove(at: col)
                gallery_imageNames.remove(at: col)
            }
            
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                
                cell.arrImagesData.remove(at: col)
                print("cell.arrImagesData.count : ", cell.arrImagesData.count)
                cell.clnCollectionView.deleteItems(at: [IndexPath(item: col, section: 0)])
                
                cell.clnCollectionView.performBatchUpdates({
                    cell.clnCollectionView.reloadData()
                    //cell.clnCollectionView.collectionViewLayout.invalidateLayout()
                }) { _ in
                    // Code to execute after reloadData and layout updates
                    self.tblView.beginUpdates()
                    self.tblView.endUpdates()
                }
            }
            
       
        
    }
}
