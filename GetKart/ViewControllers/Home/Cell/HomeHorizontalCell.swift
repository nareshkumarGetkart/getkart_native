//
//  HomeHorizontalCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 21/02/25.
//

import UIKit
import SwiftUI

class HomeHorizontalCell: UITableViewCell {
    
    @IBOutlet weak var collctnView:DynamicHeightCollectionView!
    @IBOutlet weak var lblTtitle:UILabel!
    @IBOutlet weak var btnSeeAll:UIButton!
    @IBOutlet weak var bgViewSeeAll:UIView!
    @IBOutlet weak var cnstrntHeightSeeAllView:NSLayoutConstraint!

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
       }
            return listArray?.count ?? 0
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
            
            if let obj = listArray?[indexPath.item] as? ItemModel{
                cell.lblItem.text = obj.name
                cell.lblAddress.text = obj.address
                cell.lblPrice.text =  "\(obj.price ?? 0)"
                cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            }
//            else  if let obj = listArray?[indexPath.item] as? Featured{
//                cell.lblItem.text = obj.name
//                cell.lblAddress.text = obj.address
//                cell.lblPrice.text =  "\(obj.price ?? 0)"
//                cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
//            }
            
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cellTypes == .categories{
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
            }
        }else if cellTypes == .product{
            
            let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId:(listArray?[indexPath.item] as? ItemModel)?.id ?? 0))
            AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
        }
    }
  
    
}





