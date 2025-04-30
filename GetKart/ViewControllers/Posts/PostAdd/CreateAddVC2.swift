//
//  CreateAddVC2.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit
import SwiftUI
import MapKit
class CreateAddVC2: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    var dataArray:[CustomField] = []
    var params:Dictionary<String,Any> = [:]
    var dictCustomFields:Dictionary<String,Any> = [:]
    lazy var imagePicker = UIImagePickerController()
    
    var imgData:Data?
    var imgName = ""
    var gallery_images:Array<Data> = []
    var gallery_imageNames:Array<String> = []
    var showErrorMsg = false
    var customFieldFiles :Dictionary<String,Any> = [:]
    var customFieldFilesEditPost :Dictionary<String,Any> = [:]
    var popType:PopType? = .createPost
    var itemObj:ItemModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        print(params)
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        tblView.register(UINib(nibName: "TVCell", bundle: nil), forCellReuseIdentifier: "TVCell")
        tblView.register(UINib(nibName: "RadioTVCell", bundle: nil), forCellReuseIdentifier: "RadioTVCell")
        tblView.register(UINib(nibName: "PictureAddedCell", bundle: nil), forCellReuseIdentifier: "PictureAddedCell")
        
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = UITableView.automaticDimension
        tblView.separatorColor = .clear
        // Do any additional setup after loading the view.
        if popType == .editPost {
            self.downloadCustomFieldFiles()
        }
    }
    
    func downloadCustomFieldFiles(){
        for ind in 0..<dataArray.count {
            let obj = dataArray[ind]
            if obj.type == .fileinput {
                if let url = URL(string: obj.image ?? "") {
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        //let objCustomField = self.dataArray[]
                        self.customFieldFiles["\(obj.id ?? 0)"] = data
                        self.customFieldFilesEditPost["\(obj.id ?? 0)"] = data
                        self.dictCustomFields["custom_field_files"] = self.customFieldFiles
                        DispatchQueue.main.async(execute: {
                            let indexPath = IndexPath(row: ind, section: 0)
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
                                }
                            }
                        })
                        
                    }
                    
                    task.resume()
                }
            }else {
                if let arr = obj.value as? Array<String> {
                    dictCustomFields["\(obj.id ?? 0)"] = arr
                }else  {
                    dictCustomFields["\(obj.id ?? 0)"] = Array<String>()
                }
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblView.reloadData()
    }
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func nextButtonAction (){
        showErrorMsg = false
        for objCustomField in dataArray {
            if objCustomField.customFieldRequired == 1{
                if objCustomField.type == .fileinput  {
                    let imgData =  customFieldFiles["\(objCustomField.id ?? 0)"] as? Data
                    if imgData == nil {
                        showErrorMsg = true
                        break
                    }
                    
                }else if (objCustomField.type == .checkbox ||  objCustomField.type == .radio || objCustomField.type == .dropdown) &&  objCustomField.value?.count == 0 {
                    showErrorMsg = true
                    break
                    
                }else if (objCustomField.type == .textbox ||  objCustomField.type == .number) && (objCustomField.value?.count == 0 || (objCustomField.value?.first as? String ?? "").count  < objCustomField.minLength ?? 0 ||  (objCustomField.value?.first as? String ?? "").count  > objCustomField.maxLength ?? 0) {
                showErrorMsg = true
                break
            }
            }
           
        }
        
        if showErrorMsg == true {
            tblView.reloadData()
        }else {
            for ind in 0..<self.dataArray.count {
                let objCustomField = self.dataArray[ind]
                if objCustomField.type != .fileinput {
                    if let arr = objCustomField.value as? Array<String> {
                        dictCustomFields["\(objCustomField.id ?? 0)"] = arr
                    }
                }
            }
            
            if popType == .createPost {
                if customFieldFiles.count > 0 {
                    self.dictCustomFields["custom_field_files"] = customFieldFiles
                }else {
                    self.dictCustomFields.removeValue(forKey: "custom_field_files")
                }
                params[AddKeys.custom_fields.rawValue] = self.dictCustomFields
                
                let vc = UIHostingController(rootView: ConfirmLocationCreateAdd(imgData: self.imgData, imgName: self.imgName, gallery_images: self.gallery_images, gallery_imageNames: self.gallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params))
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                
                //remove field if image is not updated
                var customFieldFilesNew :Dictionary<String,Any> = [:]
                for (key, value) in self.customFieldFiles{
                    var found = false
                    let data = value as? Data ?? Data()
                    for (key1, value1) in self.customFieldFilesEditPost {
                        let data1 = value1 as? Data ?? Data()
                        if key == key1 && data == data1  {
                            found = true
                            break
                        }
                    }
                    if found == false {
                        customFieldFilesNew[key] = value
                    }
                }
                
                if customFieldFilesNew.count > 0 {
                    self.dictCustomFields["custom_field_files"] = customFieldFilesNew
                }else {
                    self.dictCustomFields.removeValue(forKey: "custom_field_files")
                }
                params[AddKeys.custom_fields.rawValue] = self.dictCustomFields
                //only  updated images
                
                let lat = itemObj?.latitude ?? 0.0
                let lon = itemObj?.longitude ?? 0.0
                let mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                
                let selectedCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
//                 let range1: Double = 0.0
//                let circle = MKCircle(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), radius: 0.0 as CLLocationDistance)
                
                let vc = UIHostingController(rootView: ConfirmLocationCreateAdd(imgData: self.imgData, imgName: self.imgName, gallery_images: self.gallery_images, gallery_imageNames: self.gallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params, mapRegion:mapRegion, selectedCoordinate:selectedCoordinate))//,range1: range1, circle:circle))
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    func isValidInput(objCustomField:CustomField)->Bool{
        if objCustomField.customFieldRequired == 1{
            if objCustomField.type == .fileinput  {
                let imgData =  customFieldFiles["\(objCustomField.id ?? 0)"] as? Data
                if imgData == nil {
                    return false
                }
                
            }else if (objCustomField.type == .checkbox ||  objCustomField.type == .radio || objCustomField.type == .dropdown) &&  objCustomField.value?.count == 0 {
                return false
                
            }else if (objCustomField.type == .textbox ||  objCustomField.type == .number) && (objCustomField.value?.count == 0 || (objCustomField.value?.first as? String ?? "").count  < objCustomField.minLength ?? 0 ||  (objCustomField.value?.first as? String ?? "").count  > objCustomField.maxLength ?? 0) {
                return false
            }
        }
        return true
    }
    
    func showErrorMessage(objCustomField:CustomField)->String{
        var errorMsg = ""
        if objCustomField.customFieldRequired == 1 {
            if objCustomField.type  == .fileinput {
                errorMsg = "Allowed file types: PNG, JPG, JPEG, SVG, PDF"
            }else if objCustomField.type  == .dropdown || objCustomField.type  == .checkbox || objCustomField.type  == .radio{
                errorMsg = "Selecting this is required"
            }else if objCustomField.type  == .textbox || objCustomField.type  == .number {
                if objCustomField.value?.count == 0 {
                    errorMsg = "Field must not be empty."
                } else if (objCustomField.value?.first as? String ?? "").count  < objCustomField.minLength ?? 0 {
                    errorMsg = "Field minimum length is \(objCustomField.minLength ?? 0) characters."
                    
                } else if (objCustomField.value?.first as? String ?? "").count ?? 0 > objCustomField.maxLength ?? 0 {
                    errorMsg = "Field maximum length is \(objCustomField.maxLength ?? 0) characters."
                }
            }
        }
        return errorMsg
    }
    
    
}


extension CreateAddVC2:UITableViewDataSource, UITableViewDelegate, radioCellTappedDelegate, DropDownSelectionDelegate, TextFieldDoneDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var objCustomField = dataArray[indexPath.row]
        
        if objCustomField.type  == .textbox {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            //cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.imgView.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "")
            
            
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.txtField.placeholder = ""
            cell.txtField.keyboardType = .default
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            
            if  objCustomField.value?.count ?? 0 > 0 {
                    cell.txtField.text = objCustomField.value?.first ?? ""
            }else {
                objCustomField.value = Array<String>()
                    cell.txtField.text = ""
                dataArray[indexPath.row] = objCustomField
            }
                 
            if showErrorMsg == true {
                if isValidInput(objCustomField: objCustomField) == false {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = self.showErrorMessage(objCustomField: objCustomField)
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }
            
            
            cell.selectionStyle = .none
            
            return cell
            
            
        }else if objCustomField.type  == .number {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            //cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.imgView.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "")
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.txtField.placeholder = ""
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            
            
            
            if  objCustomField.value?.count ?? 0 > 0 {
                   cell.txtField.text = objCustomField.value?.first ?? ""
           }else {
                   cell.txtField.text = ""
               objCustomField.value = Array<String>()
               dataArray[indexPath.row] = objCustomField
           }
            
            
            
            
            if showErrorMsg == true {
                if isValidInput(objCustomField: objCustomField) == false {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = self.showErrorMessage(objCustomField: objCustomField)
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }
            
            cell.selectionStyle = .none
            return cell
        }else if objCustomField.type  == .radio || objCustomField.type  ==  .checkbox{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTVCell") as! RadioTVCell
            if objCustomField.value == nil {
                objCustomField.value = Array<String>()
                dataArray[indexPath.row] = objCustomField
            }
            cell.lblTitle.text = objCustomField.name ?? ""
            
            cell.imgImage.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "getkartplaceholder")
            cell.del = self
            cell.rowValue = indexPath.row
            
            if showErrorMsg == true {
                if isValidInput(objCustomField: objCustomField) == false {
                    cell.lblErrorMsg.isHidden = false
                    cell.lblErrorMsg.text = self.showErrorMessage(objCustomField: objCustomField)
                }else {
                    cell.lblErrorMsg.isHidden = true
                }
            }else {
                cell.lblErrorMsg.isHidden = true
            }

            cell.configure(with: objCustomField)
            cell.selectionStyle = .none
            return cell
        }else if objCustomField.type  == .dropdown {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            cell.imgView.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "")
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.txtField.placeholder = ""
            
            if  objCustomField.value?.count ?? 0 > 0 {
                   cell.txtField.text = objCustomField.value?.first ?? ""
           }else {
                   cell.txtField.text = ""
               objCustomField.value = Array<String>()
               dataArray[indexPath.row] = objCustomField
           }
            
            if showErrorMsg == true {
                if isValidInput(objCustomField: objCustomField) == false {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = self.showErrorMessage(objCustomField: objCustomField)
                    
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
            }
            
            cell.btnOptionBig.isHidden = false
            cell.btnOptionBig.tag = indexPath.row
            cell.btnOptionBig.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchDown)

            
            cell.btnOption.isHidden = false
            cell.btnOption.tag = indexPath.row
            cell.btnOption.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            
            return cell
        }else  if objCustomField.type  == .fileinput {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureAddedCell") as! PictureAddedCell
            cell.lblTitle.text = objCustomField.name ?? ""
            let imgData =  customFieldFiles["\(objCustomField.id ?? 0)"] as? Data
            var arr:Array<Data> = []
            if imgData != nil {
                cell.btnAddPicture.isHidden = true
                cell.clnCollectionView.isHidden = false
                arr.append(imgData ?? Data())
            }else {
                cell.btnAddPicture.isHidden = false
                cell.clnCollectionView.isHidden = true
            }
            cell.btnAddPicture.setTitle("+ Add File", for: .normal)
            cell.btnAddPicture.tag = indexPath.row
            cell.btnAddPicture.addTarget(self, action: #selector(addPictureBtnAction(_:)), for: .touchDown)
            
            
            cell.rowValue = indexPath.row
            cell.pictureAddDelegate = self
            //cell.arrImagesData = arr
            cell.configure(with: arr)
            
            
            
            if showErrorMsg == true {
                if isValidInput(objCustomField: objCustomField) == false {
                    cell.lblErrorMsg.isHidden = false
                    cell.btnAddPicture.borderColor = UIColor.red
                    cell.lblErrorMsg.text = self.showErrorMessage(objCustomField: objCustomField)
                    
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.btnAddPicture.borderColor = UIColor.lightGray
                }
            }else {
                cell.lblErrorMsg.isHidden = true
                cell.btnAddPicture.borderColor = UIColor.lightGray
            }
            
            cell.selectionStyle = .none
            return cell
            
        }
        return UITableViewCell()
    }
    
    
    
    
    func radioCellTapped(row:Int, clnCell:Int){
        print(dataArray)
        print(self.dataArray[row])
        
        var objCustomField = self.dataArray[row]
        
        if objCustomField.type == .radio {
            objCustomField.value?.removeAll()
            if let str = objCustomField.values?[clnCell] as? String {
                objCustomField.value?.append(str)
            }
            
        }else if objCustomField.type == .checkbox {
            if objCustomField.value?.contains(objCustomField.values?[clnCell]) == true {
                if let index = objCustomField.value?.firstIndex{$0 == objCustomField.values?[clnCell]} {
                    objCustomField.value?.remove(at: index)
                }else {
                    if let str = objCustomField.values?[clnCell] as? String{
                        objCustomField.value?.append(str)
                    }
                }
            }else {
                if let str = objCustomField.values?[clnCell] as? String{
                    objCustomField.value?.append(str)
                }
            }
        }
        
        dataArray[row] = objCustomField
        
        let indexPath = IndexPath(row: row, section: 0)
        if let cell = tblView.cellForRow(at: indexPath)as?
            RadioTVCell {
            cell.objData = objCustomField
            cell.clnCollectionView.reloadData()
        }
    }
    
    @objc func dropDownnAction(_ sender:UIButton) {
        print(sender.tag)
        
        if let destVC = StoryBoard.postAdd.instantiateViewController(withIdentifier: "DropDownVC")as?  DropDownVC {
            destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
            destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
            destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
            let objCustomField = self.dataArray[sender.tag]
            destVC.selectionDelegate = self
            destVC.dropDownRowIndex = sender.tag
            destVC.dataArray = objCustomField.values ?? []
            self.navigationController?.present(destVC, animated: true, completion: nil)
        }
        
    }
    
    
  
    
    func dropDownSelected(dropDownRowIndex:Int, selectedRow:Int) {
        print(dropDownRowIndex, selectedRow)
        
        var objCustomField = self.dataArray[dropDownRowIndex]
        if objCustomField.value?.count ?? 0 > 0 {
            objCustomField.value?[0] = objCustomField.values?[selectedRow] ?? ""
        }else {
            objCustomField.value?.append(objCustomField.values?[selectedRow] ?? "")
        }
        dataArray[dropDownRowIndex] = objCustomField
        let indexPath = IndexPath(row: dropDownRowIndex, section: 0)
        tblView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    
    func textFieldEditingDone(selectedRow:Int, strText:String) {
        var objCustomField = self.dataArray[selectedRow]
        if objCustomField.value?.count ?? 0 > 0 {
            objCustomField.value?[0] = strText
        }else {
            objCustomField.value?.append(strText)
        }
        print(objCustomField.value)
        dataArray[selectedRow] = objCustomField
        
    }
    
}


// MARK: ImagePicker Delegate
extension CreateAddVC2: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            
                
            let imgData = pickedImage.wxCompress().jpegData(compressionQuality: 0.0)
                imgName = "image"
            let tag = picker.navigationBar.tag
            
            let objCustomField = self.dataArray[tag]
            customFieldFiles["\(objCustomField.id ?? 0)"] = imgData
            self.dictCustomFields["custom_field_files"] = customFieldFiles
            
                let indexPath = IndexPath(row: tag, section: 0)
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
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        imagePicker.navigationBar.tag = sender.tag
        self.present(imagePicker, animated: true)
    }
     
    
    
    
    
    
    
    

   
}


extension CreateAddVC2: PictureAddedDelegate {
    func addPictureAction(row:Int) {
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        imagePicker.navigationBar.tag = row
        self.present(imagePicker, animated: true)
    }
    func removePictureAction(row:Int, col:Int) {
        
            
            
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                cell.arrImagesData.remove(at: col)
                
                let objCustomField = dataArray[row]
                customFieldFiles.removeValue(forKey: "\(objCustomField.id ?? 0)")
                
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
