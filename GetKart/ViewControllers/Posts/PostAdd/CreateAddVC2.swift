//
//  CreateAddVC2.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit
import SwiftUI
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
    @State var popType:PopType? = .createPost
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
            if objCustomField.type  == .textbox || objCustomField.type  == .number || objCustomField.type  == .dropdown{
                if  objCustomField.selectedValue == nil || objCustomField.selectedValue == "" {
                    showErrorMsg = true
                }
            }
        }
        
        if showErrorMsg == true {
            tblView.reloadData()
        }else {
            params[AddKeys.custom_fields.rawValue] = self.dictCustomFields
            let vc = UIHostingController(rootView: ConfirmLocationCreateAdd(imgData: self.imgData, imgName: self.imgName, gallery_images: self.gallery_images, gallery_imageNames: self.gallery_imageNames, navigationController: self.navigationController, popType: self.popType, params: self.params))
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
            
            if objCustomField.selectedValue == nil {
                objCustomField.selectedValue = ""
                dataArray[indexPath.row] = objCustomField
                cell.txtField.text = ""
            }else {
                cell.txtField.text = objCustomField.selectedValue
            }
            
            if showErrorMsg == true {
                if objCustomField.selectedValue == "" {
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
            if objCustomField.selectedValue == nil {
                objCustomField.selectedValue = ""
                dataArray[indexPath.row] = objCustomField
                cell.txtField.text = ""
            }else {
                cell.txtField.text = objCustomField.selectedValue
            }
            
            if showErrorMsg == true {
                if objCustomField.selectedValue == "" {
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
            
            cell.selectionStyle = .none
            return cell
        }else if objCustomField.type  == .radio || objCustomField.type  ==  .checkbox{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTVCell") as! RadioTVCell
            if objCustomField.values?.count ?? 0 != objCustomField.arrIsSelected.count  {
                
                objCustomField.arrIsSelected.append(contentsOf:repeatElement(false, count: (objCustomField.values?.count ?? 0)))
                dataArray[indexPath.row] = objCustomField
            }
            cell.lblTitle.text = objCustomField.name ?? ""
            
            //cell.imgImage.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.imgImage.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "getkartplaceholder")
            cell.objData = objCustomField
            cell.del = self
            cell.rowValue = indexPath.row
            
            
            
            cell.clnCollectionView.performBatchUpdates({
                if showErrorMsg == true {
                    var found = false
                   for obj in  objCustomField.arrIsSelected {
                       if obj == true {
                           found = true
                           break
                       }
                    }
                    if found == false {
                        cell.lblErrorMsg.isHidden = false
                    }else {
                        cell.lblErrorMsg.isHidden = true
                    }
                }else {
                    cell.lblErrorMsg.isHidden = true
                }
                cell.clnCollectionView.reloadData()
                //cell.clnCollectionView.collectionViewLayout.invalidateLayout()
            }) { _ in
                // Code to execute after reloadData and layout updates
                print("CollectionView finished updating!")
                self.tblView.beginUpdates()
                self.tblView.endUpdates()
            }
            
            cell.selectionStyle = .none
            return cell
        }else if objCustomField.type  == .dropdown {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            //cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.imgView.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "")
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.txtField.placeholder = ""
            if objCustomField.selectedValue == nil {
                objCustomField.selectedValue = ""
                dataArray[indexPath.row] = objCustomField
                cell.txtField.text = ""
            }else {
                cell.txtField.text = objCustomField.selectedValue
            }
            
            if showErrorMsg == true {
                if objCustomField.selectedValue == "" {
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
            
            cell.btnOptionBig.isHidden = false
            cell.btnOptionBig.tag = indexPath.row
            cell.btnOptionBig.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchDown)

            
            cell.btnOption.isHidden = false
            cell.btnOption.tag = indexPath.row
            cell.btnOption.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            
            return cell
        }else  if objCustomField.type  == .fileinput {
            /*
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPictureCell") as! AddPictureCell
            cell.imgView.isHidden = true
            //cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.imgView.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "")
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.lblTitle.text = objCustomField.name ?? ""
            cell.btnAddPicture.setTitle("+ Add File", for: .normal)
            cell.btnAddPicture.tag = indexPath.row
            cell.btnAddPicture.addTarget(self, action: #selector(uploadPictureBtnAction(_:)), for: .touchDown)
            return cell
             */
            
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
            
        }
        return UITableViewCell()
    }
    
    
    
    
    func radioCellTapped(row:Int, clnCell:Int){
        print(dataArray)
        print(self.dataArray[row])
        
        var objCustomField = self.dataArray[row]
        if objCustomField.arrIsSelected[clnCell] == true {
            objCustomField.arrIsSelected[clnCell] = false
            dictCustomFields.removeValue(forKey: "\(objCustomField.id ?? 0)")
        }else {
            objCustomField.arrIsSelected[clnCell] = true
            dictCustomFields["\(objCustomField.id ?? 0)"] =  objCustomField.values?[clnCell] ?? ""
        }
        if objCustomField.type == .radio {
            for ind in 0..<objCustomField.arrIsSelected.count {
                if ind != clnCell {
                    objCustomField.arrIsSelected[ind] = false
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
        objCustomField.selectedValue = objCustomField.values?[selectedRow] ?? ""
        dataArray[dropDownRowIndex] = objCustomField
        //tblView.reloadData()
        dictCustomFields["\(objCustomField.id ?? 0)"] = objCustomField.name ?? ""
        let indexPath = IndexPath(row: dropDownRowIndex, section: 0)
        tblView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    
    func textFieldEditingDone(selectedRow:Int, strText:String) {
        var objCustomField = self.dataArray[selectedRow]
        objCustomField.selectedValue = strText
        dictCustomFields["\(objCustomField.id ?? 0)"] = strText
        dataArray[selectedRow] = objCustomField
        
    }
    
}


// MARK: ImagePicker Delegate
extension CreateAddVC2: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {

   
   /* func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            print(picker.navigationBar.tag)
            let tag = picker.navigationBar.tag
                let data = pickedImage.jpegData(compressionQuality: 0.0)
                imgName = "image"
            let objCustomField = self.dataArray[tag]
            customFieldFiles["\(objCustomField.id ?? 0)"] = data
            self.dictCustomFields["custom_field_files"] = customFieldFiles
           
        }
        dismiss(animated: true, completion: nil)
        tblView.reload()
    }*/
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            
                
            let imgData = pickedImage.jpegData(compressionQuality: 0.0)
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
        self.present(imagePicker, animated: true)
    }
    func removePictureAction(row:Int, col:Int) {
        
            
            
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
