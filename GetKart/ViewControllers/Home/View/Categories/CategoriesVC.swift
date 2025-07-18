//
//  CategoriesVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 04/03/25.
//

import UIKit
import SwiftUI

class CategoriesVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collctionView:UICollectionView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var tblView:UITableView!
    var popType:PopType?
    private var objViewModel:CategoryViewModel?
     
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnBack.setImageColor(color: .label)
        collctionView.showsVerticalScrollIndicator = false
        tblView.showsVerticalScrollIndicator = false
        if popType == .filter || popType == .buyPackage {
            collctionView.isHidden = true
            tblView.isHidden = false
            tblView.register(UINib(nibName: "CategoriesTVCell", bundle: nil), forCellReuseIdentifier: "CategoriesTVCell")
            
        }else {
            collctionView.isHidden = false
            tblView.isHidden = true
            collctionView.register(UINib(nibName: "CategoriesBigCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesBigCell")
        }
            objViewModel = CategoryViewModel()
            objViewModel?.delegate = self
        
        
    }
    
    //MARK: UIButton Action Methods
    @IBAction  func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension CategoriesVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if popType == .filter  || popType == .buyPackage{
            return 0
        }else {
            return objViewModel?.listArray?.count ?? 0
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:  (self.collctionView.bounds.size.width/3.0 - 3) , height: 160)
        
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesBigCell", for: indexPath) as! CategoriesBigCell
     
        DispatchQueue.main.async {
            cell.imageBgView.backgroundColor = UIColor(hexString: "#fff7e9")
            cell.imageBgView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 15.0)
            cell.imageBgView.clipsToBounds = true
            cell.bgView.layer.borderColor = UIColor.lightGray.cgColor
            cell.bgView.layer.borderWidth = 1.5
            cell.bgView.layer.cornerRadius = 10.0
            cell.bgView.clipsToBounds = true
        }
        
        if let obj = objViewModel?.listArray?[indexPath.item] as? CategoryModel{
            cell.lblTitle.text = obj.name
            cell.imgView.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        }
                
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if popType == .categoriesSeeAll{
            let objCategory = objViewModel?.listArray?[indexPath.item]

            if objCategory?.subcategories?.count ?? 0 > 0{
                let objCategory = objViewModel?.listArray?[indexPath.item]
                let swiftUIView = SubCategoriesView(subcategories: objCategory?.subcategories, navigationController: self.navigationController, strTitle: objCategory?.name ?? "",category_id:"\(objCategory?.id ?? 0)", category_ids:"\(objCategory?.id ?? 0)", popType:self.popType) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                navigationController?.pushViewController(hostingController, animated: true)
            }else{
                
                let vc = UIHostingController(rootView: SearchWithSortView(categroryId: objCategory?.id ?? 0, navigationController:self.navigationController, categoryName: objCategory?.name ?? "",categoryIds: "\(objCategory?.id ?? 0)", categoryImg:objCategory?.image ?? ""))

                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if popType == .buyPackage{
            
            
        }else{
        //if popType == .createPost {
            
            
            let objCategory = objViewModel?.listArray?[indexPath.item]
            if (objCategory?.subcategories?.count ?? 0) > 0 {
                let swiftUIView = SubCategoriesView(subcategories: objCategory?.subcategories, navigationController: self.navigationController, strTitle: objCategory?.name ?? "",category_id:"\(objCategory?.id ?? 0)", category_ids:"\(objCategory?.id ?? 0)", popType:self.popType) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                navigationController?.pushViewController(hostingController, animated: true) //
            }else{
                if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                    vc.objSubCategory = nil
                    vc.strCategoryTitle = objCategory?.name ?? ""
                    vc.strSubCategoryTitle =  ""
                    vc.category_ids = "\(objCategory?.id ?? 0)"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
   // func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
//    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
   
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
           // print("up")
            if scrollView == collctionView{
                return
            }else if scrollView == tblView{
                return
            }
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 70)
        {
           // if scrollView == collctionView{
                if objViewModel?.isDataLoading == false{
                    objViewModel?.getCategoriesListApi()
                }
           // }
        }
    }
}


extension CategoriesVC:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if popType == .filter || popType == .buyPackage {
            return objViewModel?.listArray?.count ?? 0
        }else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTVCell") as! CategoriesTVCell
        if let obj = objViewModel?.listArray?[indexPath.item] as? CategoryModel{
            cell.lblTitle.text = obj.name
            cell.imgImageView.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        }
       
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if popType == .buyPackage {
            let objCategory = objViewModel?.listArray?[indexPath.item]
            
            for vc in self.navigationController?.viewControllers ?? []{
                if let vc1 = vc as? CategoryPlanVC  {
                    vc1.saveCategoryInfo(category_id: objCategory?.id ?? 0, categoryName: objCategory?.name ?? "")
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
            
        }else if popType == .filter {
            
            let objCategory = objViewModel?.listArray?[indexPath.item]
            
            if (objCategory?.subcategories?.count ?? 0) == 0{
                
                for vc in self.navigationController?.viewControllers ?? []{
                    if let vc1 = vc as? FilterVC  {
                        vc1.strCategoryTitle = objCategory?.name ?? ""
                        vc1.category_id = "\(objCategory?.id ?? 0)"
                        vc1.category_ids = "\(objCategory?.id ?? 0)"
                        vc1.fetchCustomFields()
                        self.navigationController?.popToViewController(vc1, animated: true)
                    }
                }
                
            }else{
                
              
                
                let swiftUIView = SubCategoriesView(subcategories: objCategory?.subcategories, navigationController: self.navigationController, strTitle: objCategory?.name ?? "", category_id: "\(objCategory?.id ?? 0)", category_ids:"\(objCategory?.id ?? 0)", popType:self.popType,screenNumber: 1) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                navigationController?.pushViewController(hostingController, animated: true)
            }
        }
    }
    
    
   
}

extension CategoriesVC: RefreshScreen{
    func refreshScreen(){
        if popType == .filter || popType == .buyPackage {
            tblView.reloadData()
        }else {
            self.collctionView.reloadData()
        }
    }
}
