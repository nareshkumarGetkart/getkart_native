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
        
        tblView.separatorColor = .clear
        // Do any additional setup after loading the view.
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
/*

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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objCustomField = dataArray[indexPath.row]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlmostThereCell") as! AlmostThereCell
            cell.lblCategory.text = strCategoryTitle
            cell.lblSubCategory.text = "> \(strSubCategoryTitle)"
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Add Title"
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TVCell") as! TVCell
            cell.lblTitle.text = "Description"
            return cell
        }else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPictureCell") as! AddPictureCell
            cell.lblTitle.text = "Main Picture(Max 3MB)"
            cell.btnAddPicture.setTitle("Add Main Picture", for: .normal)
            return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPictureCell") as! AddPictureCell
            cell.lblTitle.text = "Other Pictures(Max 5 Images)"
            cell.btnAddPicture.setTitle("Add Other Pictures", for: .normal)
            return cell
        }else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Price"
            return cell
        }else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Phone Number"
            return cell
        }else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TFCell") as! TFCell
            cell.lblTitle.text = "Video Link"
            cell.txtField.placeholder = "http://example.com/video.mp4"
            return cell
        }
        return UITableViewCell()
    }
}
*/
