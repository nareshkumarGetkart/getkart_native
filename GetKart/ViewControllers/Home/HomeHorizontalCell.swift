//
//  HomeHorizontalCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 21/02/25.
//

import UIKit

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
    
}


extension HomeHorizontalCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if cellTypes == .categories{
            return listArray?.count ?? 0
//        }
//        return  10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if cellTypes == .categories{
            return CGSize(width: self.collctnView.bounds.size.width/3.0, height: 130)
        }else{
            
        
            return CGSize(width: self.collctnView.bounds.size.width/2.0 - 2.5 , height: 260)
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
                cell.lblPrice.text =  "\(obj.price ?? 0)"
                cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            }else  if let obj = listArray?[indexPath.item] as? Featured{
                cell.lblItem.text = obj.name
                cell.lblAddress.text = obj.address
                cell.lblPrice.text =  "\(obj.price ?? 0)"
                cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            }
            
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
    
}





