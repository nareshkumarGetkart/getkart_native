//
//  HomeTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit
import Kingfisher
import SwiftUI


enum CellType{
    
    case product
    case categories
}


protocol CollectionTableViewCellDelegate: AnyObject {
    func didUpdateCollectionViewHeight()
}

class HomeTblCell: UITableViewCell {
    
    @IBOutlet weak var cllctnView:DynamicHeightCollectionView!
    @IBOutlet weak var lblTtitle:UILabel!
    @IBOutlet weak var btnSeeAll:UIButton!
    @IBOutlet weak var bgViewSeeAll:UIView!
    @IBOutlet weak var cnstrntHeightSeeAllView:NSLayoutConstraint!
    weak var delegateUpdate: CollectionTableViewCellDelegate?
    
    var cellTypes:CellType?
    var listArray:[Any]?
    var istoIncreaseWidth = false
    var navigationController: UINavigationController?
    
    var section = 0
    var rowIndex = 0
    weak var delegateUpdateList:UPdateListDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctnView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")
        cllctnView.register(UINib(nibName: "CategoriesCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesCell")
        self.cllctnView.delegate = self
        self.cllctnView.dataSource = self
    }
   
    /*
     https://adminweb.getkart.com/images/app_styles/style_1.png
     https://adminweb.getkart.com/images/app_styles/style_2.png
     https://adminweb.getkart.com/images/app_styles/style_3.png
     https://adminweb.getkart.com/images/app_styles/style_4.png
     */
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}


extension HomeTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return listArray?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if cellTypes == .categories{
            return CGSize(width: self.cllctnView.bounds.size.width/3.0 + 60, height: 130)
        }else{
        
            let widthCell = (istoIncreaseWidth) ? (self.cllctnView.bounds.size.width/2.0 + 20.0) : (self.cllctnView.bounds.size.width/2.0 - 2.5)
            return CGSize(width: widthCell , height: 260)
        }
    }
       

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if cellTypes == .categories{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
            
            if let obj = listArray?[indexPath.item] as? CategoryModel{
                cell.lblTitle.text = obj.name
                cell.imgView.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            }
            
            return cell
            
        }else  if cellTypes == .product{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.bgView.addShadow()
            if let obj = listArray?[indexPath.item] as? ItemModel{
                cell.lblItem.text = obj.name
                cell.lblAddress.text = obj.address
                cell.lblPrice.text =  "\(Local.shared.currencySymbol) \((obj.price ?? 0.0).formatNumber())"
                cell.lblBoost.isHidden = ((obj.isFeature ?? false) == true) ? false : true

                let imgName = (obj.isLiked ?? false) ? "like_fill" : "like"
                cell.btnLike.setImage(UIImage(named: imgName), for: .normal)
                
                cell.btnLike.tag = indexPath.item
                cell.btnLike.addTarget(self, action: #selector(likebtnAction), for: .touchUpInside)
                cell.btnLike.backgroundColor = .systemBackground

                if let originalImage = UIImage(named: "location-outline") {
                    let tintedImage = originalImage.tinted(with: .label)
                    cell.imgViewLoc.image = tintedImage
                }
                
                let processor = DownsamplingImageProcessor(size: cell.imgViewitem.bounds.size)
                
                cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") ,
                                             placeholder:UIImage(named: "getkartplaceholder"),
                                             options: [
                                                .processor(processor),
                                                .scaleFactor(UIScreen.main.scale)
                                             ])

            }

            return cell

        }
        
        return UICollectionViewCell()
        
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   
        if cellTypes == .product{
            
            var detailView = ItemDetailView(navController: self.navigationController, itemId:(listArray?[indexPath.item] as? ItemModel)?.id ?? 0, itemObj: (listArray?[indexPath.item] as? ItemModel), slug: (listArray?[indexPath.item] as? ItemModel)?.slug)
            detailView.returnValue = { [weak self] value in
               if let obj = value{
                   self?.listArray?[indexPath.item] = obj
                   self?.delegateUpdateList?.updateArray(section: self?.section ?? 0, rowIndex: self?.rowIndex ?? 0, arrIndex: indexPath.item, obj: obj)
                   self?.cllctnView.reloadItems(at: [indexPath])
               }
           }
            let hostingController = UIHostingController(rootView:detailView )
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
        }
    }
    
    
    @objc  func likebtnAction(_ sender : UIButton){
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            
            if  var obj = (listArray?[sender.tag] as? ItemModel){
                obj.isLiked?.toggle()
                listArray?[sender.tag] = obj
                addToFavourite(itemId:obj.id ?? 0)
                delegateUpdateList?.updateArray(section: section, rowIndex: rowIndex, arrIndex: sender.tag, obj: obj)

                self.cllctnView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                
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



class DynamicHeightCollectionView: UICollectionView {
   override func layoutSubviews() {
   super.layoutSubviews()
   if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
      self.invalidateIntrinsicContentSize()
   }
 }

   override var intrinsicContentSize: CGSize {
     return collectionViewLayout.collectionViewContentSize
   }
    
    override var contentSize: CGSize {
      didSet {
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        layoutIfNeeded()
      }
    }
}
