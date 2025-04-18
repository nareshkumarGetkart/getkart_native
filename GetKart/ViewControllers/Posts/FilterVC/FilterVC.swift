//
//  FilterVC.swift
//  GetKart
//
//  Created by gurmukh singh on 3/31/25.
//

import UIKit
import SwiftUI

protocol FilterSelected{
    func filterSelectectionDone(dict:Dictionary<String,Any>)
}

class FilterVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnBack:UIButton!

    var latitude:String = ""
    var longitude:String = ""
    var city:String = ""
    var state:String = ""
    var country:String = ""
    
    var dataArray:[CustomField] = []
    var dictCustomFields:Dictionary<String,Any> = [:]
    
    var strCategoryTitle = ""
    var category_ids = ""
    var category_id = ""
    var min_price = ""
    var max_price = ""
    var isPushedFromHome = false
    var arrPostedSinceDict:Array<Dictionary<String,String>> = [["status": "All Time", "value": "all-time"], ["status": "Today", "value": "today"], ["status": "Within 1 week", "value": "within-1-week"], ["status": "Within 2 week", "value": "within-2-week"], ["status": "Within 1 month", "value": "within-1-month"], ["status": "Within 3 month", "value": "within-3-month"]]
    var posted_since:Dictionary<String,String> = [:]
    var objViewModel:CustomFieldsViewModel?
    var delFilterSelected:FilterSelected?
   

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        for ind in 0..<4 {
            let obj = CustomField(id: ind, name: "", type: .none, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
            self.dataArray.append(obj)
        }
        
       // self.dataArray.append(contentsOf: [CustomField(),CustomField(),CustomField(),CustomField()])
        btnBack.setImageColor(color: .black)
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "RadioTVCell", bundle: nil), forCellReuseIdentifier: "RadioTVCell")
        
        tblView.register(UINib(nibName: "BudgetTblViewCell", bundle: nil), forCellReuseIdentifier: "BudgetTblViewCell")
        tblView.register(UINib(nibName: "imgWithBtnViewCell", bundle: nil), forCellReuseIdentifier: "imgWithBtnViewCell")
        
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = UITableView.automaticDimension
        tblView.separatorColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(strCategoryTitle)
        tblView.reloadData()
    }
    
    deinit{
        print("dinit called")
    }

    
    //MARK: UIButton Action Methods
    @IBAction  func backButtonAction(_ sender : UIButton){
        
        if isPushedFromHome{
            self.navigationController?.popToRootViewController(animated: true)

        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction  func resetBtnAction(){
        latitude = ""
        longitude = ""
        city = ""
        state = ""
        country = ""
        
        self.dataArray.removeAll()
        for ind in 0..<4 {
            let obj = CustomField(id: ind, name: "", type: .none, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
            self.dataArray.append(obj)
        }
        //self.dataArray.append(contentsOf: [CustomFields(),CustomFields(),CustomFields(),CustomFields()])
        dictCustomFields.removeAll()
        strCategoryTitle = ""
        category_ids = ""
        category_id = ""
        min_price = ""
        max_price = ""
        
        posted_since.removeAll()
        
        tblView.reloadData()
    }
    
    @IBAction  func applyFilterAction() {
        dictCustomFields["max_price"] = max_price
        dictCustomFields["min_price"] = min_price
        dictCustomFields["category_id"] =  category_id
        dictCustomFields["posted_since"] = posted_since["value"]
        dictCustomFields["city"] = city
        dictCustomFields["state"] = self.state
        dictCustomFields["country"] = self.country
        //dictCustomFields["radius"] = s
        
        dictCustomFields["longitude"] = self.longitude
        dictCustomFields["latitude"] = self.latitude
        
        delFilterSelected?.filterSelectectionDone(dict: dictCustomFields)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func selectLocationAction (_ sender:UIButton){
        if sender.tag == 0 {
            self.fetchCountryListing()
        }
    }
    
    func fetchCustomFields() {
        if objViewModel == nil {
            objViewModel = CustomFieldsViewModel()
        }
        objViewModel?.delegate = self
        objViewModel?.getCustomFieldsListApi(category_ids: category_ids)
    }
    
    
    func fetchCountryListing(){
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            let arrCountry = obj.data?.data ?? []
           let vc = UIHostingController(rootView: CountryLocationView(arrCountries: arrCountry, popType: .filter, navigationController: self.navigationController))
           self.navigationController?.pushViewController(vc, animated: true)
       }
   }
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String) {

        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
        
        self.tblView.reloadData()
        
    }
    
    @objc func showCategoriesVC(){
        if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
            destVC.popType = .filter
            AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
        }
    }

}

extension FilterVC:UITableViewDataSource, UITableViewDelegate, radioCellTappedDelegate, DropDownSelectionDelegate, TextFieldDoneDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < 4{
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "imgWithBtnViewCell") as! imgWithBtnViewCell
                cell.btnTextValue.tag = indexPath.row
                cell.btnArrowDown.tag = indexPath.row
                
                if indexPath.row == 0 {
                    cell.lblTitle.text = "Location"
                    cell.imgImageView.image = UIImage(named: "location_icon")
                    var strTitle = ""
                    if country.count > 0 {
                        strTitle = city + ", " + state + ", " + country
                    }
                    cell.btnTextValue.setTitle(strTitle, for: .normal)
                    cell.btnTextValue.removeTarget(nil, action: nil, for: .allEvents)
                    cell.btnArrowDown.removeTarget(nil, action: nil, for: .allEvents)
                    cell.btnTextValue.addTarget(self, action: #selector(selectLocationAction(_:)), for: .touchUpInside)
                    
                    
                    
                    cell.btnArrowDown.isHidden = true
                }else if indexPath.row == 1 {
                    cell.lblTitle.text = "Category"
                    cell.imgImageView.image = UIImage(named: "category_icon")
                    if strCategoryTitle.count == 0{
                        let strTitle = "All in Classified"
                        cell.btnTextValue.setTitle(strTitle, for: .normal)
                    }else {
                        cell.btnTextValue.setTitle(strCategoryTitle, for: .normal)
                    }
                    cell.btnTextValue.removeTarget(nil, action: nil, for: .allEvents)
                    cell.btnArrowDown.removeTarget(nil, action: nil, for: .allEvents)
                    
                    cell.btnTextValue.addTarget(self, action: #selector(showCategoriesVC), for: .touchUpInside)
                    
                    cell.btnArrowDown.isHidden = false
                }else if indexPath.row == 3 {
                    cell.lblTitle.text = "Posted Since"
                    cell.imgImageView.image = UIImage(named: "since_icon")
                    if posted_since["status"]?.count == 0 {
                        let strTitle = "All time"
                        cell.btnTextValue.setTitle(strTitle, for: .normal)
                    }else {
                        cell.btnTextValue.setTitle(posted_since["status"], for: .normal)
                    }
                    
                    cell.btnTextValue.removeTarget(nil, action: nil, for: .allEvents)
                    cell.btnArrowDown.removeTarget(nil, action: nil, for: .allEvents)
                    
                    cell.btnTextValue.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchUpInside)
                    
                    
                    cell.btnArrowDown.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchUpInside)

                    cell.btnArrowDown.isHidden = false
                }
                cell.selectionStyle = .none
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetTblViewCell") as! BudgetTblViewCell
                cell.lblTitle.text = "Budget (Price)"
                cell.txtLowerRange.tag = 100
                cell.txtLowerRange.delegate = self
                cell.txtLowerRange.text = min_price
                cell.txtLowerRange.keyboardType = .numberPad
                
                cell.txtUpperRange.tag = 101
                cell.txtUpperRange.delegate = self
                cell.txtUpperRange.text = max_price
                cell.txtUpperRange.keyboardType = .numberPad
                
                cell.selectionStyle = .none
                
                return cell
            }
        }else {
            
            var objCustomField = dataArray[indexPath.row]
            if objCustomField.type  == .radio || objCustomField.type  ==  .checkbox{
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
                    cell.clnCollectionView.reloadData()
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
                cell.btnOptionBig.isHidden = false
                cell.btnOptionBig.tag = indexPath.row
                cell.btnOptionBig.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchDown)
                
                
                cell.btnOption.isHidden = false
                cell.btnOption.tag = indexPath.row
                cell.btnOption.addTarget(self, action: #selector(dropDownnAction(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    
    
    
    func radioCellTapped(row:Int, clnCell:Int){
        print(dataArray)
        print(self.dataArray[row])
        
        var objCustomField = self.dataArray[row]
        if objCustomField.arrIsSelected[clnCell] == true {
            objCustomField.arrIsSelected[clnCell] = false
            dictCustomFields.removeValue(forKey: "custom_fields[\(objCustomField.id ?? 0)]")
        }else {
            objCustomField.arrIsSelected[clnCell] = true
            dictCustomFields["custom_fields[\(objCustomField.id ?? 0)]"] =  "[\(objCustomField.values?[clnCell] ?? "")]"
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
        if sender.tag != 0 {
            if let destVC = StoryBoard.postAdd.instantiateViewController(withIdentifier: "DropDownVC")as?  DropDownVC {
                destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
                destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
                destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                if sender.tag == 3 {
                    let values = self.arrPostedSinceDict.compactMap { $0["status"] }
                    destVC.dataArray = values
                }else {
                    let objCustomField = self.dataArray[sender.tag]
                    destVC.dataArray = objCustomField.values ?? []
                }
                destVC.selectionDelegate = self
                destVC.dropDownRowIndex = sender.tag
                
                self.navigationController?.present(destVC, animated: true, completion: nil)
            }
        }
        
    }
    
    
  
    
    func dropDownSelected(dropDownRowIndex:Int, selectedRow:Int) {
        print(dropDownRowIndex, selectedRow)
        if dropDownRowIndex == 3 {
            posted_since = arrPostedSinceDict[selectedRow]
        }else {
            var objCustomField = self.dataArray[dropDownRowIndex]
            objCustomField.selectedValue = objCustomField.values?[selectedRow] ?? ""
            dataArray[dropDownRowIndex] = objCustomField
            //tblView.reloadData()
            dictCustomFields["\(objCustomField.id ?? 0)"] = objCustomField.name ?? ""
        }
        
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

extension FilterVC:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        print(updatedText)
        if textField.tag == 100 {
            min_price = updatedText
        }else  if textField.tag == 101 {
            max_price = updatedText
        }
        return true
    }
}


extension FilterVC:RefreshScreen {
    func refreshScreen() {
        print(self.objViewModel?.dataArray)
        self.dataArray.removeAll()
        
        //self.dataArray.append(contentsOf: [CustomFields(),CustomFields(),CustomFields(),CustomFields()])
        for ind in 0..<4 {
            let obj = CustomField(id: ind, name: "", type: .none, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
            self.dataArray.append(obj)
        }
        
        for objCustomField in self.objViewModel?.dataArray ?? [] {
            if objCustomField.type == .radio || objCustomField.type  ==  .checkbox || objCustomField.type  == .dropdown{
                self.dataArray.append(objCustomField)
            }
        }
            
        tblView.reloadData()
        
    }
}
