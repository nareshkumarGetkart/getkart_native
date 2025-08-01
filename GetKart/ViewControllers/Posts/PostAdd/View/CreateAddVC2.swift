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
    @IBOutlet weak var btnBack:UIButton!
    var dataArray:[CustomField] = []
    var params:Dictionary<String,Any> = [:]
    var dictCustomFields:Dictionary<String,Any> = [:]
    lazy private var imagePicker = UIImagePickerController()
    var imgData:Data?
    var imgName = ""
    var gallery_images:Array<Data> = []
    var gallery_imageNames:Array<String> = []
    var showErrorMsg = false
    var customFieldFiles :Dictionary<String,Any> = [:]
    var customFieldFilesEditPost :Dictionary<String,Any> = [:]
    var popType:PopType? = .createPost
    var itemObj:ItemModel?
    var selectedRow = -1
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnBack.setImageColor(color: .label)
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        tblView.register(UINib(nibName: "TVCell", bundle: nil), forCellReuseIdentifier: "TVCell")
        tblView.register(UINib(nibName: "RadioTVCell", bundle: nil), forCellReuseIdentifier: "RadioTVCell")
        tblView.register(UINib(nibName: "PictureAddedCell", bundle: nil), forCellReuseIdentifier: "PictureAddedCell")
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = UITableView.automaticDimension
        tblView.separatorColor = .clear
        
        if popType == .editPost {
            self.downloadCustomFieldFiles()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblView.reloadData()
        tblView.performBatchUpdates(nil) { _ in
            self.tblView.beginUpdates()
            self.tblView.endUpdates()
        }
    }
    
    
    //MARK: Other Helpful Methods
    func downloadCustomFieldFiles(){
        for ind in 0..<dataArray.count {
            let obj = dataArray[ind]
            if obj.type == .fileinput {
                
                guard let arr = obj.value,arr.count > 0 else{ continue}
                
                if let strURl  = arr.first , let url = URL(string: strURl ?? "") {
                
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
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
                                    arr.append(data)
                                    cell.arrImagesData = arr
                                    cell.clnCollectionView!.insertItems(at: [IndexPath(item: 0, section: 0)])
                                }else {
                                    cell.arrImagesData.removeAll()
                                    var arr:Array<Data> = []
                                    arr.append(data)
                                    cell.arrImagesData = arr
                                }
                                
                                cell.reloadCollection()
                                self.tblView.beginUpdates()
                                self.tblView.endUpdates()
                          
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

    //MARK: UIButton Action Methods
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonAction (){
        showErrorMsg = false
        
        var scrollIndex = -1

        for objCustomField in dataArray {
            
            scrollIndex = scrollIndex + 1
            
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
                }else if (objCustomField.type == .number) && objCustomField.name == "Year"{
                    
                    if isValidManufacturingYear((objCustomField.value?.first as? String ?? "")) == false{
                        showErrorMsg = true
                        break
                    }
                }
            }
        }
        
        if showErrorMsg == true {
            tblView.reloadData()

            if scrollIndex >= 0{
                tblView.scrollToRow(at: IndexPath(row: scrollIndex, section: 0), at: .middle, animated: true)
            }
            
        }else{
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
                
                let vc = ConfirmLocationHostingController(rootView: ConfirmLocationCreateAdd(imgData: self.imgData, imgName: self.imgName, gallery_images: self.gallery_images, gallery_imageNames: self.gallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params))
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
                
                print("self.params second page == \(self.params)")
                let swiftLocView = ConfirmLocationCreateAdd(latitiude:itemObj?.latitude ?? 0.0, longitude:itemObj?.longitude ?? 0.0, imgData: self.imgData, imgName: self.imgName, gallery_images: self.gallery_images, gallery_imageNames: self.gallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params)
                let vc = ConfirmLocationHostingController(rootView: swiftLocView)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    
    func isValidManufacturingYear(_ input: String) -> Bool {
        // Check if it's a 4-digit number
        guard let year = Int(input), input.count == 4 else {
            return false
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Set a reasonable range (e.g., 1900 to current year + 1)
        return year >= 1900 && year <= currentYear // + 1
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
        }else  if objCustomField.type  == .textbox || objCustomField.type  == .number {
            if (objCustomField.value?.first as? String ?? "").count > 0{
                
                if (objCustomField.value?.first as? String ?? "").count < objCustomField.minLength ?? 0 {
                    return false
                }else  if (objCustomField.value?.first as? String ?? "").count > objCustomField.maxLength ?? 0 {
                    return false
                }
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
                errorMsg = "Selecting \(objCustomField.name ?? "") is required"
            }else if objCustomField.type  == .textbox || objCustomField.type  == .number {
                if objCustomField.value?.count == 0 {
                    errorMsg = "\(objCustomField.name ?? "") must not be empty."
                } else if (objCustomField.value?.first as? String ?? "").count  < objCustomField.minLength ?? 0 {
                    errorMsg = "\(objCustomField.name ?? "") minimum length is \(objCustomField.minLength ?? 0) characters."
                    
                } else if (objCustomField.value?.first as? String ?? "").count > objCustomField.maxLength ?? 0 {
                    errorMsg = "\(objCustomField.name ?? "") maximum length is \(objCustomField.maxLength ?? 0) characters."
                }
            }
        }else if objCustomField.type  == .textbox || objCustomField.type  == .number {
            
            if (objCustomField.value?.first as? String ?? "").count > 0 {
                
                if  (objCustomField.value?.first as? String ?? "").count < objCustomField.minLength ?? 0  {
                    errorMsg = "\(objCustomField.name ?? "") minimum length is \(objCustomField.minLength ?? 0) characters."
                }else if  (objCustomField.value?.first as? String ?? "").count > objCustomField.maxLength ?? 0{
                    
                    errorMsg = "\(objCustomField.name ?? "") maximum length is \(objCustomField.maxLength ?? 0) characters."
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
            cell.selectionStyle = .none
            cell.iconBgView.isHidden = false
            cell.imgView.isHidden = false
           
            if (objCustomField.image ?? "").lowercased().contains(".svg") {
                cell.imgView.isHidden = true
                cell.iconImgWebView.isHidden = false
                cell.iconImgWebView.loadSVGURL(iconUrl: objCustomField.image ?? "")
                
            }else{
                cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
                cell.imgView.isHidden = false
                cell.iconImgWebView.isHidden = true
            }
            
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.txtField.placeholder = ""
            cell.txtField.keyboardType = .default
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            
            if (objCustomField.maxLength ?? 0) > 0{
                cell.txtField.maxLength = objCustomField.maxLength ?? 0
            }else{
            }
            
            if  objCustomField.value?.count ?? 0 > 0 {
                cell.txtField.text = objCustomField.value?.first ?? ""
            }else {
                objCustomField.value = Array<String>()
                cell.txtField.text = ""
                dataArray[indexPath.row] = objCustomField
            }
            
            if showErrorMsg == true  && selectedRow != indexPath.row{
                if isValidInput(objCustomField: objCustomField) == false  {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = self.showErrorMessage(objCustomField: objCustomField)
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else{
                cell.lblErrorMsg.isHidden = true
                cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
            }
            
            return cell
            
            
        }else if objCustomField.type  == .number {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.selectionStyle = .none
            cell.imgView.isHidden = false
            cell.iconBgView.isHidden = false
            
            if (objCustomField.image ?? "").lowercased().contains(".svg") {
                cell.imgView.isHidden = true
                cell.iconImgWebView.isHidden = false
                cell.iconImgWebView.loadSVGURL(iconUrl: objCustomField.image ?? "")
                
            }else{
                cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
                cell.imgView.isHidden = false
                cell.iconImgWebView.isHidden = true
            }
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.txtField.placeholder = ""
            cell.txtField.keyboardType = .numberPad
            cell.txtField.tag = indexPath.row
            cell.btnOption.isHidden = true
            cell.btnOptionBig.isHidden = true
            cell.textFieldDoneDelegate = self
            if (objCustomField.maxLength ?? 0) > 0{
                cell.txtField.maxLength = objCustomField.maxLength ?? 0
            }else{
                
            }

            if  objCustomField.value?.count ?? 0 > 0 {
                cell.txtField.text = objCustomField.value?.first ?? ""
            }else{
                cell.txtField.text = ""
                objCustomField.value = Array<String>()
                dataArray[indexPath.row] = objCustomField
            }
            
            if showErrorMsg == true  && selectedRow != indexPath.row{
                if isValidInput(objCustomField: objCustomField) == false {
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = self.showErrorMessage(objCustomField: objCustomField)
               
                }else if (isValidManufacturingYear((objCustomField.value?.first as? String ?? "")) == false) && objCustomField.name == "Year"{
                    cell.lblErrorMsg.isHidden = false
                    cell.txtField.layer.borderColor = UIColor.red.cgColor
                    cell.lblErrorMsg.text = "Please enter valid year."
                }else {
                    cell.lblErrorMsg.isHidden = true
                    cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
                }
            }else{
                cell.lblErrorMsg.isHidden = true
                cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
            }
            
            return cell
        }else if objCustomField.type  == .radio || objCustomField.type  ==  .checkbox{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTVCell") as! RadioTVCell
            cell.selectionStyle = .none

            if objCustomField.value == nil {
                objCustomField.value = Array<String>()
                dataArray[indexPath.row] = objCustomField
            }
            cell.lblTitle.text = objCustomField.name ?? ""
                        
            if (objCustomField.image ?? "").lowercased().contains(".svg") {
                cell.imgImage.isHidden = true
                cell.iconImgWebView.isHidden = false
                cell.iconImgWebView.loadSVGURL(iconUrl: objCustomField.image ?? "")
                
            }else{
                cell.imgImage.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
                cell.imgImage.isHidden = false
                cell.iconImgWebView.isHidden = true
            }
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
            
            //Adjust the table cell height as per contents
            cell.clnCollectionView.performBatchUpdates({
                
            }) { _ in
                // Code to execute after reloadData and layout updates
                self.tblView.beginUpdates()
                self.tblView.endUpdates()
            }
                    
            return cell
        }else if objCustomField.type  == .dropdown {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            cell.iconBgView.isHidden = false
            if (objCustomField.image ?? "").lowercased().contains(".svg") {
                cell.imgView.isHidden = true
                cell.iconImgWebView.isHidden = false
                cell.iconImgWebView.loadSVGURL(iconUrl: objCustomField.image ?? "")
            }else{
                cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
                cell.imgView.isHidden = false
                cell.iconImgWebView.isHidden = true
            }
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
                    
                }else{
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
            cell.selectionStyle = .none
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
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    
    
    func radioCellTapped(row:Int, clnCell:Int){
       // print(dataArray)
       // print(self.dataArray[row])
        
        var objCustomField = self.dataArray[row]
        
        if objCustomField.type == .radio {
            
            if objCustomField.value?.contains(objCustomField.values?[clnCell]) == true {
                objCustomField.value?.removeAll()

            }else{
                objCustomField.value?.removeAll()
                if let str = objCustomField.values?[clnCell] as? String {
                    objCustomField.value?.append(str)
                }
            }
        }else if objCustomField.type == .checkbox {
            if objCustomField.value?.contains(objCustomField.values?[clnCell]) == true {
                if let index = objCustomField.value?.firstIndex(where: {$0 == objCustomField.values?[clnCell]}) {
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
            tblView.beginUpdates()
            cell.lblErrorMsg.isHidden = true
            cell.clnCollectionView.reloadData()
            tblView.endUpdates()
        }
    }
    
    @objc func dropDownnAction(_ sender:UIButton) {
       // print(sender.tag)
        
        if let destVC = StoryBoard.postAdd.instantiateViewController(withIdentifier: "DropDownVC")as?  DropDownVC {
            destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
            destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
           // destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
           
            let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
            let theme = AppTheme(rawValue: savedTheme) ?? .system
            
            if theme == .dark{
                destVC.view.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8) // Semi-transparent background
            }else{
                destVC.view.backgroundColor = UIColor.label.withAlphaComponent(0.8) // Semi-transparent background
            }
            let objCustomField = self.dataArray[sender.tag]
            destVC.selectionDelegate = self
            destVC.dropDownRowIndex = sender.tag
            destVC.dataArray = objCustomField.values ?? []
            self.navigationController?.present(destVC, animated: true, completion: nil)
        }
    }
        
    
    func dropDownSelected(dropDownRowIndex:Int, selectedRow:Int) {
       // print(dropDownRowIndex, selectedRow)
        
        var objCustomField = self.dataArray[dropDownRowIndex]
        if objCustomField.value?.count ?? 0 > 0 {
            objCustomField.value?[0] = objCustomField.values?[selectedRow] ?? ""
        }else {
            objCustomField.value?.append(objCustomField.values?[selectedRow] ?? "")
        }
        dataArray[dropDownRowIndex] = objCustomField
        let indexPath = IndexPath(row: dropDownRowIndex, section: 0)
        tblView.reloadRows(at: [indexPath], with: .automatic)
        self.tblView.reloadData()

     }
    
    func textFieldEditingDone(selectedRow:Int, strText:String) {
        self.selectedRow = -1
        var objCustomField = self.dataArray[selectedRow]
        if objCustomField.value?.count ?? 0 > 0 {
            objCustomField.value?[0] = strText
        }else {
            objCustomField.value?.append(strText)
        }
       // print(objCustomField.value)
        dataArray[selectedRow] = objCustomField
        self.tblView.reloadData()
    }
    
    func textFieldEditingBegin(selectedRow:Int, strText:String)
    {
        self.selectedRow = selectedRow
        
        if let cell = tblView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? TFCell{
            tblView.beginUpdates()
            cell.lblErrorMsg.isHidden = true
            cell.txtField.layer.borderColor = UIColor.opaqueSeparator.cgColor
            tblView.endUpdates()
        }
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
        
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.navigationBar.tag = tag
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
    }
}


extension CreateAddVC2: PictureAddedDelegate {
    
    func addPictureAction(row:Int) {
        showImagePickerOptions(tag: row)
    }
        
    func removePictureAction(row:Int, col:Int) {
                    
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = self.tblView.cellForRow(at: indexPath) as? PictureAddedCell {
                cell.arrImagesData.remove(at: col)
                
                let objCustomField = dataArray[row]
                customFieldFiles.removeValue(forKey: "\(objCustomField.id ?? 0)")
                
               // print("cell.arrImagesData.count : ", cell.arrImagesData.count)
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

