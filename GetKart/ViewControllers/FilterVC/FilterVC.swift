//
//  FilterVC.swift
//  GetKart
//
//  Created by gurmukh singh on 3/31/25.
//

import UIKit
import SwiftUI

class FilterVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    
    var latitude:String = ""
    var longitude:String = ""
    var city:String = ""
    var state:String = ""
    var country:String = ""
    
    var dataArray:[CustomFields] = []
    var dictCustomFields:Dictionary<String,Any> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "RadioTVCell", bundle: nil), forCellReuseIdentifier: "RadioTVCell")
        tblView.register(UINib(nibName: "BudgetTblViewCell", bundle: nil), forCellReuseIdentifier: "BudgetTblViewCell")
        tblView.register(UINib(nibName: "imgWithBtnViewCell", bundle: nil), forCellReuseIdentifier: "imgWithBtnViewCell")
        
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = UITableView.automaticDimension
        tblView.separatorColor = .clear
    }
    

    
    
    @objc func selectLocationAction (){
        self.fetchCountryListing()
    }
    func fetchCountryListing(){
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            let arrCountry = obj.data?.data ?? []
           let vc = UIHostingController(rootView: CountryLocationView(navigationController: self.navigationController, arrCountries: arrCountry, isFilterList: true))
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
            destVC.isFilter = true
            AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
        }
    }

}

extension FilterVC:UITableViewDataSource, UITableViewDelegate, radioCellTappedDelegate, DropDownSelectionDelegate, TextFieldDoneDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }else {
            return dataArray.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "imgWithBtnViewCell") as! imgWithBtnViewCell
                if indexPath.row == 0 {
                    cell.lblTitle.text = "Location"
                    cell.imgImageView.image = UIImage(named: "location_icon")
                    let strTitle = city + ", " + state + ", " + country
                    cell.btnTextValue.setTitle(strTitle, for: .normal)
                    cell.btnTextValue.addTarget(self, action: #selector(selectLocationAction), for: .touchUpInside)
                    cell.btnArrowDown.isHidden = true
                }else if indexPath.row == 1 {
                    cell.lblTitle.text = "Category"
                    cell.imgImageView.image = UIImage(named: "")
                    let strTitle = "All in Classified"
                    cell.btnTextValue.setTitle(strTitle, for: .normal)
                    cell.btnTextValue.addTarget(self, action: #selector(showCategoriesVC), for: .touchUpInside)
                    
                    cell.btnArrowDown.isHidden = false
                }else if indexPath.row == 3 {
                    cell.lblTitle.text = "Posted Since"
                    cell.imgImageView.image = UIImage(named: "")
                    let strTitle = "All time"
                    cell.btnTextValue.setTitle(strTitle, for: .normal)
                    cell.btnTextValue.addTarget(self, action: #selector(selectLocationAction), for: .touchUpInside)
                    cell.btnArrowDown.isHidden = false
                }
                cell.selectionStyle = .none
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetTblViewCell") as! BudgetTblViewCell
                cell.lblTitle.text = "Budget (Price)"
                cell.txtLowerRange.tag = 100
                //cell.txtLowerRange.delegate = self
                
                cell.txtUpperRange.tag = 101
                //cell.txtUpperRange.delegate = self
                cell.selectionStyle = .none
                
                return cell
            }
        }else {
            
            var objCustomField = dataArray[indexPath.row]
            if objCustomField.type ?? "" == "radio" || objCustomField.type ?? "" ==  "checkbox"{
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
                    //cell.clnCollectionView.collectionViewLayout.invalidateLayout()
                }) { _ in
                    // Code to execute after reloadData and layout updates
                    print("CollectionView finished updating!")
                    self.tblView.beginUpdates()
                    self.tblView.endUpdates()
                }
                
                cell.selectionStyle = .none
                return cell
            }else if objCustomField.type ?? "" == "dropdown" {
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
            dictCustomFields.removeValue(forKey: "\(objCustomField.id ?? 0)")
        }else {
            objCustomField.arrIsSelected[clnCell] = true
            dictCustomFields["\(objCustomField.id ?? 0)"] =  objCustomField.values?[clnCell] ?? ""
        }
        if objCustomField.type == "radio" {
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
