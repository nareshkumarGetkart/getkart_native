//
//  CreateAddDetailVC.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit

class CreateAddDetailVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    var objCategory: CategoryModel?
    var objSubCategory:Subcategory?
    
    var numberOfPictures = 2
    var strCategoryTitle = ""
    var strSubCategoryTitle = ""
    var category_ids = ""
    
    var objViewModel:CustomFieldsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tblView.register(UINib(nibName: "AlmostThereCell", bundle: nil), forCellReuseIdentifier: "AlmostThereCell")
        tblView.register(UINib(nibName: "TFCell", bundle: nil), forCellReuseIdentifier: "TFCell")
        tblView.register(UINib(nibName: "TVCell", bundle: nil), forCellReuseIdentifier: "TVCell")
        tblView.register(UINib(nibName: "AddPictureCell", bundle: nil), forCellReuseIdentifier: "AddPictureCell")
        tblView.separatorColor = .clear
        
        objViewModel = CustomFieldsViewModel()
        objViewModel?.delegate = self
        objViewModel?.getCustomFieldsListApi(category_ids: category_ids)
        
    }
    
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func nextButtonAction() {
        if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddVC2") as? CreateAddVC2 {
            vc.dataArray = self.objViewModel?.dataArray ?? []
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension CreateAddDetailVC:RefreshScreen {
    func refreshScreen() {
        print(self.objViewModel?.dataArray)
    }
}

extension CreateAddDetailVC:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 + numberOfPictures
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
