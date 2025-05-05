//
//  HomeHorizontalCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 21/02/25.
//

import UIKit
import SwiftUI
import Kingfisher

class HomeHorizontalCell: UITableViewCell {
    
    @IBOutlet weak var collctnView:DynamicHeightCollectionView!
    @IBOutlet weak var lblTtitle:UILabel!
    @IBOutlet weak var btnSeeAll:UIButton!
    @IBOutlet weak var bgViewSeeAll:UIView!
    @IBOutlet weak var cnstrntHeightSeeAllView:NSLayoutConstraint!
    var navigationController: UINavigationController?
    
    var cellTypes:CellType?{
        didSet{
            if cnstrntHeightSeeAllView.constant == 0{
                btnSeeAll.setTitle("", for: .normal)
            }else{
                btnSeeAll.setTitle("See All", for: .normal)
                
            }
        }
    }
    weak var delegateUpdate: CollectionTableViewCellDelegate?
    var istoIncreaseWidth = false
    
    var listArray:[Any]?
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            // self.delegateUpdate?.didUpdateCollectionViewHeight()
        }
    }
    
}


extension HomeHorizontalCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cellTypes == .categories{
            return (listArray?.count ?? 0) > 0 ?  (listArray?.count ?? 0) + 1 : 0
        }else{
            return listArray?.count ?? 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if cellTypes == .categories{
            return CGSize(width: self.collctnView.bounds.size.width/3.0 - 35, height: 130)
        }else{
                
            let widthCell = (istoIncreaseWidth) ? (self.collctnView.bounds.size.width/2.0 + 20.0) : (self.collctnView.bounds.size.width/2.0 - 2.5)

            return CGSize(width: widthCell , height: 260)
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cellTypes == .categories{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
           
            if (listArray?.count ?? 0) == indexPath.item{
                cell.imgView.image = UIImage(named:"moreHor")
                cell.lblTitle.text = "More"
                cell.imgView.layer.borderColor = UIColor.lightGray.cgColor
                cell.imgView.layer.borderWidth = 1.0
                cell.imgView.isHidden = false
                cell.threeDotImgView.isHidden = false
                cell.imgView.image = nil
                
            }else if let obj = listArray?[indexPath.item] as? CategoryModel{
                cell.lblTitle.text = obj.name
                cell.imgView.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
                cell.imgView.layer.borderColor = UIColor.clear.cgColor
                cell.imgView.layer.borderWidth = 0.0
                cell.imgView.contentMode = .scaleAspectFill
                cell.imgView.isHidden = false
                cell.threeDotImgView.isHidden = true


            }
            
            cell.imgView.layer.cornerRadius = 10.0
            cell.imgView.clipsToBounds = true
            return cell
            
        }else  if cellTypes == .product{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.bgView.addShadow()
            
            if indexPath.item < listArray?.count ?? 0{
                if let obj = listArray?[indexPath.item] as? ItemModel{
                    cell.lblItem.text = obj.name
                    cell.lblAddress.text = obj.address
                    cell.lblPrice.text =  "\(Local.shared.currencySymbol) \(obj.price ?? 0)"
                    // cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
                    let imgName = (obj.isLiked ?? false) ? "like_fill" : "like"
                    cell.btnLike.setImage(UIImage(named: imgName), for: .normal)
                    cell.btnLike.tag = indexPath.item
                    cell.btnLike.addTarget(self, action: #selector(likebtnAction), for: .touchUpInside)
                    
                    
                    
                    
                    let processor = DownsamplingImageProcessor(size: cell.imgViewitem.bounds.size)
                    
                    cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"), options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale)
                    ])
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
                
                let vc = UIHostingController(rootView: SearchWithSortView(categroryId: obj?.id ?? 0, navigationController:self.navigationController, categoryName: obj?.name ?? ""))
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if cellTypes == .product{
            
            var swiftUIview =  ItemDetailView(navController:  self.navigationController, itemId:(listArray?[indexPath.item] as? ItemModel)?.id ?? 0, itemObj: (listArray?[indexPath.item] as? ItemModel), slug: (listArray?[indexPath.item] as? ItemModel)?.slug)
             swiftUIview.returnValue = { value in
                if let obj = value{
                    self.listArray?[indexPath.item] = obj
                    self.collctnView.reloadItems(at: [indexPath])
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
                self.collctnView.reloadData()
                
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
}





