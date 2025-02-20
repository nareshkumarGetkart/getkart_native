//
//  HomeTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit


enum CellType{
    
    case product
    case categories
}


class HomeTblCell: UITableViewCell {

    @IBOutlet weak var cllctnView:UICollectionView!
    @IBOutlet weak var lblTtitle:UILabel!
    @IBOutlet weak var btnSeeAll:UIButton!
    @IBOutlet weak var bgViewSeeAll:UIView!

    var cellTypes:CellType?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctnView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")
        cllctnView.register(UINib(nibName: "CategoriesCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesCell")
        self.cllctnView.delegate = self
        self.cllctnView.dataSource = self
    }

    
    func updateLayout(){
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


extension HomeTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cellTypes == .categories{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
            
            return cell
            
        }else  if cellTypes == .product{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
    
    
    
}


