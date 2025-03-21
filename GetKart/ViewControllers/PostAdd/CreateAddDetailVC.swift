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
    var objCategory: CategoryModel?
    var objSubCategory:Subcategory?
    
    var numberOfPictures = 2
    var strCategoryTitle = ""
    var strSubCategoryTitle = ""
    var category_ids = ""
    
    var objViewModel:CustomFieldsViewModel?
    var params:Dictionary<String,Any> = [:]
    lazy var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tblView.register(UINib(nibName: "AlmostThereCell", bundle: nil), forCellReuseIdentifier: "AlmostThereCell")
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        tblView.register(UINib(nibName: "TVCell", bundle: nil), forCellReuseIdentifier: "TVCell")
        tblView.register(UINib(nibName: "AddPictureCell", bundle: nil), forCellReuseIdentifier: "AddPictureCell")
        tblView.separatorColor = .clear
        
        objViewModel = CustomFieldsViewModel()
        objViewModel?.delegate = self
        objViewModel?.getCustomFieldsListApi(category_ids: category_ids)
        
        params[AddKeys.all_category_ids.rawValue] = category_ids
        params[AddKeys.category_id.rawValue] = objSubCategory?.id ?? 0
        params[AddKeys.show_only_to_premium.rawValue] = 0
        
    }
    
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func nextButtonAction() {
        if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddVC2") as? CreateAddVC2 {
            vc.dataArray = self.objViewModel?.dataArray ?? []
            vc.params = self.params
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
            
            
            
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TVCell") as! TVCell
            cell.lblTitle.text = "Description"
            cell.textViewDoneDelegate = self
            cell.tvTextView.tag = indexPath.row
            return cell
        }else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPictureCell") as! AddPictureCell
            cell.lblTitle.text = "Main Picture(Max 3MB)"
            cell.btnAddPicture.setTitle("Add Main Picture", for: .normal)
            cell.btnAddPicture.tag = indexPath.row
            cell.btnAddPicture.addTarget(self, action: #selector(uploadPictureBtnAction(_:)), for: .touchDown)
            return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPictureCell") as! AddPictureCell
            cell.lblTitle.text = "Other Pictures(Max 5 Images)"
            cell.btnAddPicture.setTitle("Add Other Pictures", for: .normal)
            cell.btnAddPicture.tag = indexPath.row
            cell.btnAddPicture.addTarget(self, action: #selector(uploadPictureBtnAction(_:)), for: .touchDown)
            return cell
        }else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Price"
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            
            return cell
        }else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Phone Number"
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
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
            self.uploadFIleToServer(img: pickedImage, name: "file")
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
    
    @objc func uploadPictureBtnAction(_ sender:UIButtonX){
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    func uploadFIleToServer(img:UIImage,name:String){
        
        
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: img, imageName: "file", url: Constant.shared.upload_chat_files, params: [:]) { responseObject, error in

            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        if let fileStr = data["file"] as? String{
                            
                            //self.sendMessageList(msg: fileStr, msgType: "file")
                        }
                        
                        if let audio = data["audio"] as? String{
                           // self.sendMessageList(msg: audio, msgType: "audio")
                        }
                 
                        
                    }
                }
            }
        }
    }
   
}
