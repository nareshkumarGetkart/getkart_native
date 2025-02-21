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

    var cellTypes:CellType?
    

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
        return  10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if cellTypes == .categories{
            return CGSize(width: self.collctnView.bounds.size.width/3.0 + 60, height: 130)
        }else{
            
        
            return CGSize(width: self.collctnView.bounds.size.width/2.0 - 2.5 , height: 260)
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cellTypes == .categories{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
            
            return cell
            
        }else  if cellTypes == .product{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.bgView.addShadow()
            
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
    
}





