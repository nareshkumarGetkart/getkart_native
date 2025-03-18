//
//  CreateAddVC2.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit

class CreateAddVC2: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    var dataArray:[CustomFields] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        tblView.register(UINib(nibName: "TVCell", bundle: nil), forCellReuseIdentifier: "TVCell")
        tblView.register(UINib(nibName: "RadioTVCell", bundle: nil), forCellReuseIdentifier: "RadioTVCell")
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
        
        if objCustomField.type ?? "" == "textbox" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.lblTitle.text = objCustomField.name ?? ""
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
            cell.selectionStyle = .none
            
            return cell
            
            
        }else if objCustomField.type ?? "" == "number" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.lblTitle.text = objCustomField.name ?? ""
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
            cell.selectionStyle = .none
            return cell
        }else if objCustomField.type ?? "" == "radio" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTVCell") as! RadioTVCell
            if objCustomField.values?.count ?? 0 != objCustomField.arrIsSelected.count  {
                
                objCustomField.arrIsSelected.append(contentsOf:repeatElement(false, count: (objCustomField.values?.count ?? 0)))
                dataArray[indexPath.row] = objCustomField
            }
            cell.lblTitle.text = objCustomField.name ?? ""
            
            cell.imgImage.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
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
            
           /* DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute:  {
                self.tblView.beginUpdates()
                self.tblView.endUpdates()
            })*/
            
            return cell
        }else if objCustomField.type ?? "" == "dropdown" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.imgView.isHidden = false
            cell.imgView.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.lblTitle.text = objCustomField.name ?? ""
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
        return UITableViewCell()
    }
    
    func radioCellTapped(row:Int, clnCell:Int){
        print(dataArray)
        print(self.dataArray[row])
        
        var objCustomField = self.dataArray[row]
        if objCustomField.arrIsSelected[clnCell] == true {
            objCustomField.arrIsSelected[clnCell] = false
        }else {
            objCustomField.arrIsSelected[clnCell] = true
        }
        for ind in 0..<objCustomField.arrIsSelected.count {
            if ind != clnCell {
                objCustomField.arrIsSelected[ind] = false
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
        
        let indexPath = IndexPath(row: dropDownRowIndex, section: 0)
        tblView.reloadRows(at: [indexPath], with: .automatic)
        
        
    }
    
    func textFieldEditingDone(selectedRow:Int, strText:String) {
        var objCustomField = self.dataArray[selectedRow]
        objCustomField.selectedValue = strText
        dataArray[selectedRow] = objCustomField
        
    }
    
}

