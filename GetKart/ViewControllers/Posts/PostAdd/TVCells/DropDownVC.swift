//
//  DropDownVC.swift
//  GetKart
//
//  Created by gurmukh singh on 3/17/25.
//

import UIKit
protocol DropDownSelectionDelegate {
    func dropDownSelected(dropDownRowIndex:Int, selectedRow:Int)
}
class DropDownVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    var dataArray:[String?] = []
    var dropDownRowIndex = 0
    var selectionDelegate:DropDownSelectionDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "DropDownTVCell", bundle: nil), forCellReuseIdentifier: "DropDownTVCell")
        tblView.layer.cornerRadius = 10.0
        tblView.clipsToBounds = true
        // Do any additional setup after loading the view.
        
       // self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedView)))
    }
    

//    @objc  func tappedView(){
//        self.dismiss(animated: true, completion: nil)
//
//    }

    @IBAction func closeButtonAction(_ sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }

}
extension DropDownVC:UITableViewDataSource, UITableViewDelegate {
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
        
        var strData = dataArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownTVCell") as! DropDownTVCell
        cell.lblTitle.text = dataArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionDelegate?.dropDownSelected(dropDownRowIndex: dropDownRowIndex, selectedRow: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
}
