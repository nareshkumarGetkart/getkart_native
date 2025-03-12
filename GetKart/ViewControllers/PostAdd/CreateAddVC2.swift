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


extension CreateAddVC2:UITableViewDataSource, UITableViewDelegate {
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
            cell.lblTitle.text = "Add Title"
            return cell
        }else if objCustomField.type ?? "" == "radio" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTVCell") as! RadioTVCell
            if objCustomField.values?.count ?? 0 != objCustomField.arrIsSelected?.count ?? 0 {
                objCustomField.arrIsSelected?.append(contentsOf:repeatElement(false, count: (objCustomField.values?.count ?? 0)))
                dataArray[indexPath.row] = objCustomField
            }
            cell.lblTitle.text = objCustomField.name ?? ""
            
            cell.imgImage.kf.setImage(with:  URL(string: objCustomField.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.objData = objCustomField
            
            cell.clnCollectionView.invalidateIntrinsicContentSize()
            cell.clnCollectionView.setNeedsLayout()
            cell.clnCollectionView.layoutIfNeeded()
            
            cell.clnCollectionView.reloadData()
            self.tblView.beginUpdates()
            self.tblView.endUpdates()
        
            
            return cell
        }else if objCustomField.type ?? "" == "dropdown" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Price"
            return cell
        }
        return UITableViewCell()
    }
}

