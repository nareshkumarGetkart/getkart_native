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
    var isNewPost = false
    
    private var objViewModel:CategoryViewModel?
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnBack.setImageColor(color: .black)
        
        collctionView.register(UINib(nibName: "CategoriesBigCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesBigCell")
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
        return objViewModel?.listArray?.count ?? 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:  (self.collctionView.bounds.size.width/3.0 - 3) , height: 160)
        
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesBigCell", for: indexPath) as! CategoriesBigCell
        cell.bgView.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgView.layer.borderWidth = 1.0
        cell.bgView.layer.cornerRadius = 10.0
        cell.bgView.clipsToBounds = true
        cell.imgView.layer.cornerRadius = 15.0
        cell.imgView.clipsToBounds = true
        
        if let obj = objViewModel?.listArray?[indexPath.item] as? CategoryModel{
            cell.lblTitle.text = obj.name
            cell.imgView.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
           // cell.imgView.layer.borderColor = UIColor.clear.cgColor
          //  cell.imgView.layer.borderWidth = 0.0
        }
       
      //  cell.bgView.addShadow()

                
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isNewPost == true {
            let objCategory = objViewModel?.listArray?[indexPath.item]
            let swiftUIView = SubCategoriesView(subcategories: objCategory?.subcategories, navigationController: self.navigationController, isNewPost: true, strTitle: objCategory?.name ?? "", category_ids:"\(objCategory?.id ?? 0)") // Create SwiftUI view
            let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
            navigationController?.pushViewController(hostingController, animated: true) //
        }
    }
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        
//        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
//            print("up")
//            if scrollView == collctionView{
//                return
//            }
//        }
//        
//        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 70)
//        {
//            if scrollView == collctionView{
//                if objViewModel?.isDataLoading == false{
//                    objViewModel?.getItemListApi()
//                }
//            }
//        }
//    }
    
}


extension CategoriesVC: RefreshScreen{
    func refreshScreen(){
        self.collctionView.reloadData()
    }
}
