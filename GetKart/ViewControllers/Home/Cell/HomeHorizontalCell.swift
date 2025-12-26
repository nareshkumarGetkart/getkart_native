//
//  HomeHorizontalCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 21/02/25.
//

import UIKit
import SwiftUI
import Kingfisher
import FittedSheets

protocol UPdateListDelegate:AnyObject{
    
    func updateArray(section:Int,rowIndex:Int,arrIndex:Int,obj:Any?)
}
class HomeHorizontalCell: UITableViewCell {
    
    @IBOutlet weak var collctnView:DynamicHeightCollectionView!
    @IBOutlet weak var lblTtitle:UILabel!
    @IBOutlet weak var btnSeeAll:UIButton!
    @IBOutlet weak var bgViewSeeAll:UIView!
    @IBOutlet weak var cnstrntHeightSeeAllView:NSLayoutConstraint!
    var navigationController: UINavigationController?
  
    var cellTypes: CellType? {
        didSet {
            btnSeeAll.setTitle(cnstrntHeightSeeAllView.constant == 0 ? "" : "See All", for: .normal)
        }
    }
    
    weak var delegateUpdate: CollectionTableViewCellDelegate?
    var istoIncreaseWidth = false
    var listArray:[Any]?
    var section = 0
    var rowIndex = 0
    weak var delegateUpdateList:UPdateListDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collctnView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")
        collctnView.register(UINib(nibName: "CategoriesCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesCell")
        self.collctnView.delegate = self
        self.collctnView.dataSource = self
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}


extension HomeHorizontalCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {  1 }
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       return (cellTypes == .categories) ? ((listArray?.count ?? 0) > 0 ? (listArray?.count ?? 0) + 1 : 0) : (listArray?.count ?? 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.bounds.height
        let widthCell: CGFloat = (cellTypes == .categories) ? 87 : (istoIncreaseWidth ? collectionView.bounds.width / 2.0 + 21.0 : collectionView.bounds.width / 2.0 - 11.5)
        return CGSize(width: widthCell, height: height)
    }
    
   

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if cellTypes == .categories {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
            cell.prepareForReuse()
            if indexPath.item == listArray?.count {
                cell.configureAsMoreCell()
            } else if let obj = listArray?[indexPath.item] as? CategoryModel {
                cell.configure(with: obj)
            }
            return cell
            
        } else if cellTypes == .product {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.prepareForReuse()
            if (listArray?.count ?? 0) > indexPath.item{
                if let obj = listArray?[indexPath.item] as? ItemModel {
                    cell.configure(with: obj, index: indexPath.item, likeAction: #selector(likebtnAction))
                    
                    cell.btnIsVerified.tag = indexPath.item
                    cell.btnIsVerified.addTarget(self, action: #selector(presentVerifiedView), for: .touchUpInside)
                }
            }
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cellTypes == .categories{
            
            if (listArray?.count ?? 0) == indexPath.item{
                
                if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                    destVC.popType = .categoriesSeeAll
                    destVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
                return
            }
            
            let obj = listArray?[indexPath.item] as? CategoryModel

            if obj?.subcategories?.count ?? 0 > 0 {
                
                let swiftUIView = SubCategoriesView(subcategories: obj?.subcategories, navigationController:  self.navigationController, strTitle: obj?.name ?? "",category_id:"\(obj?.id ?? 0)", category_ids:"\(obj?.id ?? 0)", popType: .categoriesSeeAll) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
            }else{
                
                let vc = UIHostingController(rootView: SearchWithSortView(categroryId: obj?.id ?? 0, navigationController:self.navigationController, categoryName: obj?.name ?? "", categoryIds: "\(obj?.id ?? 0)", categoryImg:  obj?.image ?? ""))
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if cellTypes == .product{
            
            var swiftUIview =  ItemDetailView(navController:  self.navigationController, itemId:(listArray?[indexPath.item] as? ItemModel)?.id ?? 0, itemObj: (listArray?[indexPath.item] as? ItemModel), slug: (listArray?[indexPath.item] as? ItemModel)?.slug)
            swiftUIview.returnValue = { [weak self] value in
                if let obj = value{
                    self?.listArray?[indexPath.item] = obj
                    self?.collctnView.reloadItems(at: [indexPath])
                    self?.delegateUpdateList?.updateArray(section: self?.section ?? 0, rowIndex: self?.rowIndex ?? 0, arrIndex: indexPath.item, obj: obj)
                }
            }
            
            let hostingController = UIHostingController(rootView:swiftUIview)
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
        }
    }
  
    @objc  func likebtnAction(_ sender : UIButton){
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            
            if  var obj = (listArray?[sender.tag] as? ItemModel){
                obj.isLiked?.toggle()
                listArray?[sender.tag] = obj
                collctnView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                delegateUpdateList?.updateArray(section: section, rowIndex: rowIndex, arrIndex: sender.tag, obj: obj)
                addToFavourite(itemId:obj.id ?? 0)
            }
        }
    }

    
    func addToFavourite(itemId:Int){
        
        let params = ["item_id":"\(itemId)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                
            }
        }
    }
    
    @objc func presentVerifiedView(){
  
        AppDelegate.sharedInstance.presentVerifiedInfoView()

    }
}



