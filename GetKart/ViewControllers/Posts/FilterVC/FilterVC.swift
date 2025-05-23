//
//  FilterVC.swift
//  GetKart
//
//  Created by gurmukh singh on 3/31/25.
//

import UIKit
import SwiftUI

protocol FilterSelected{
    func filterSelectectionDone(dict:Dictionary<String,Any>, dataArray:Array<CustomField>, strCategoryTitle:String)
}

class FilterVC: UIViewController, LocationSelectedDelegate {
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnBack:UIButton!
    
    var latitude:String = ""
    var longitude:String = ""
    var city:String = ""
    var state:String = ""
    var country:String = ""
    var radius:Double = 0.0
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
        if self.dataArray.count == 0 {
            for ind in 0..<4 {
                let obj = CustomField(id: ind, name: "", type: .none, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
                self.dataArray.append(obj)
            }
            
            city = Local.shared.getUserCity()
            self.state = Local.shared.getUserState()
            self.country = Local.shared.getUserCountry()
            self.latitude = Local.shared.getUserLatitude()
            self.longitude = Local.shared.getUserLongitude()
            
            
        }else {
            max_price = dictCustomFields["max_price"] as? String ?? ""
            min_price = dictCustomFields["min_price"] as? String ?? ""
            category_id = dictCustomFields["category_id"] as? String ?? ""
            
            for obj in arrPostedSinceDict {
                if obj["value"] == dictCustomFields["posted_since"]  as? String ?? "" {
                    posted_since = obj
                    break
                }
            }
            //posted_since["value"] = dictCustomFields["posted_since"]  as? String ?? ""
            
            city = dictCustomFields["city"] as? String ?? ""
            self.state = dictCustomFields["state"] as? String ?? ""
            self.country = dictCustomFields["country"] as? String ?? ""
            radius = dictCustomFields["radius"] as? Double ?? 0.0
            self.latitude = dictCustomFields["latitude"] as? String ?? ""
            self.longitude = dictCustomFields["longitude"] as? String ?? ""
            
        }
        
        btnBack.setImageColor(color: .label)
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
        self.view.endEditing(true)
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
        if radius != 0{
            dictCustomFields["radius"] = radius
        }
        
        dictCustomFields["longitude"] = self.longitude
        dictCustomFields["latitude"] = self.latitude
        
        delFilterSelected?.filterSelectectionDone(dict: dictCustomFields, dataArray:self.dataArray, strCategoryTitle: self.strCategoryTitle)
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
            var rootView = CountryLocationView(arrCountries: arrCountry, popType: .filter, navigationController: self.navigationController)
            rootView.delLocationSelected = self
            let vc = UIHostingController(rootView:rootView )
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func savePostLocationWithRange(latitude:String, longitude:String,  city:String, state:String, country:String, range:Double = 0.0) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
        self.radius = range
        self.tblView.reloadData()
    }
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
        //self.radius = range
        self.tblView.reloadData()
    }
    
    @objc func showCategoriesVC(){
        if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
            destVC.popType = .filter
            self.navigationController?.pushViewController(destVC, animated: true)
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
                   // var strTitle = ""
                    
                    var address = ""
                    if city.count > 0 {
                        address = city
                    }
                    
                    if state.count > 0 {
                        address =  address.count > 0 ? (address + ", " + state) : state
                    }
                    
                    if country.count > 0 {
                        address =  address.count > 0 ? (address + ", " + country) : country
                    }
                    
                   /* if address.count == 0 {
                        address = "All Countries"
                    }*/
                    
                    cell.btnTextValue.setTitle(address, for: .normal)
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
                    cell.btnArrowDown.addTarget(self, action: #selector(showCategoriesVC), for: .touchUpInside)

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
               // cell.txtLowerRange.delegate = self
                cell.txtLowerRange.text = min_price
                cell.txtLowerRange.keyboardType = .numberPad
                cell.txtLowerRange.placeholder = "Min"
                cell.textFieldDoneFirstDelegate = self
                cell.showCurrencySymbolFirst = true

                cell.txtUpperRange.tag = 101
              //  cell.txtUpperRange.delegate = self
                cell.txtUpperRange.text = max_price
                cell.txtUpperRange.keyboardType = .numberPad
                cell.txtUpperRange.placeholder = "Max"
                cell.textFieldSecondDoneDelegate = self
                cell.showCurrencySymbolSecond = true
                cell.selectionStyle = .none
                
                cell.txtLowerRange.maxLength = 10
                cell.txtUpperRange.maxLength = 10

                if min_price.count > 0 {
                    cell.lblCurSymbolLowRange.isHidden = false
                    cell.txtLowerRange.leftPadding = 15
                }
                
                if max_price.count > 0 {
                    cell.lblCurSymbolUpperRange.isHidden = false
                    cell.txtUpperRange.leftPadding = 15
                }
                
                cell.lblCurSymbolLowRange.text = Local.shared.currencySymbol
                cell.lblCurSymbolUpperRange.text = Local.shared.currencySymbol

                
                return cell
            }
        }else {
            
            var objCustomField = dataArray[indexPath.row]
            if objCustomField.type  == .radio || objCustomField.type  ==  .checkbox{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTVCell") as! RadioTVCell
                if objCustomField.value == nil {
                    objCustomField.value = Array<String>()
                    dataArray[indexPath.row] = objCustomField
                }
                cell.lblTitle.text = objCustomField.name ?? ""
                
                cell.imgImage.loadSVGImagefromURL(strurl: objCustomField.image ?? "", placeHolderImage: "getkartplaceholder")
                cell.del = self
                cell.rowValue = indexPath.row
                
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
                   objCustomField.value = Array<String?>()
                   dataArray[indexPath.row] = objCustomField
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
        
        if objCustomField.type == .radio {
            objCustomField.value?.removeAll()
            if let str = objCustomField.values?[clnCell] as? String {
                objCustomField.value?.append(str)
                dictCustomFields["\(objCustomField.id ?? 0)"] = objCustomField.values?[clnCell] ?? ""
            }
            
        }else if objCustomField.type == .checkbox {
            if objCustomField.value?.contains(objCustomField.values?[clnCell]) == true {
                if let index = objCustomField.value?.firstIndex(where: {$0 == objCustomField.values?[clnCell]}) {
                    objCustomField.value?.remove(at: index)
                    let joinedStr = objCustomField.value?.compactMap{$0}.joined(separator: ", ")
                    dictCustomFields["\(objCustomField.id ?? 0)"] = joinedStr
                     
                }else {
                    if let str = objCustomField.values?[clnCell] as? String{
                        objCustomField.value?.append(str)
                        let joinedStr = objCustomField.value?.compactMap{$0}.joined(separator: ", ")
                        dictCustomFields["\(objCustomField.id ?? 0)"] = joinedStr
                    }
                }
            }else {
                if let str = objCustomField.values?[clnCell] as? String{
                    objCustomField.value?.append(str)
                    let joinedStr = objCustomField.value?.compactMap{$0}.joined(separator: ", ")
                    dictCustomFields["\(objCustomField.id ?? 0)"] = joinedStr
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
            if objCustomField.value?.count ?? 0 > 0 {
                objCustomField.value?[0] = objCustomField.values?[selectedRow] ?? ""
                dictCustomFields["\(objCustomField.id ?? 0)"] = objCustomField.values?[selectedRow] ?? ""
            }else {
                objCustomField.value?.append(objCustomField.values?[selectedRow] ?? "")
                dictCustomFields["\(objCustomField.id ?? 0)"] = objCustomField.values?[selectedRow] ?? ""
            }
            dataArray[dropDownRowIndex] = objCustomField
        }
        let indexPath = IndexPath(row: dropDownRowIndex, section: 0)
        tblView.reloadRows(at: [indexPath], with: .automatic)
        
    }

    
    
    func textFieldEditingDone(selectedRow:Int, strText:String) {
        
        if selectedRow == 100{
            min_price = strText
        }else if selectedRow == 101 {
            max_price = strText
        }else{
            var objCustomField = self.dataArray[selectedRow]
            if objCustomField.value?.count ?? 0 > 0 {
                objCustomField.value?[0] = strText
            }else {
                objCustomField.value?.append(strText)
            }
            dataArray[selectedRow] = objCustomField
        }
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

/*
extension FilterVC: TextFieldDoneDelegate, TextViewDoneDelegate{
    
    func textFieldEditingDone(selectedRow:Int, strText:String) {
        print(selectedRow, strText)
        print( AddKeys.name)
        if selectedRow == 100{
            min_price = strText
        }else if selectedRow == 101 {
            max_price = strText
        }
        
    }
    
    
    func textViewEditingDone(selectedRow:Int, strText:String) {
        if selectedRow == 2 {
            params[AddKeys.description.rawValue] = strText
        }
    }
}
*/
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
