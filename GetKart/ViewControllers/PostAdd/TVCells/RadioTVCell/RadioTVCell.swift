//
//  radioTVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/11/25.
//

import UIKit

class RadioTVCell: UITableViewCell {
    @IBOutlet weak var imgImage:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var clnCollectionView:DynamicHeightCollectionView!
    @IBOutlet weak var clnHeight:NSLayoutConstraint!
    
    var objData:CustomFields!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clnCollectionView.register(UINib(nibName: "RadioBtnCVCell", bundle: .main), forCellWithReuseIdentifier: "RadioBtnCVCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func buttonClicked(sender:UIButton)
    {
        print("Tag: ", sender.tag)
        let indexPath = IndexPath(index: sender.tag)
        if let cell =  clnCollectionView.cellForItem(at: indexPath) as? RadioBtnCVCell {
            if objData.arrIsSelected?[indexPath.item] == true {
                objData.arrIsSelected?[indexPath.item] = false
                cell.btnValue.titleLabel?.textColor = .orange
            }else {
                objData.arrIsSelected?[indexPath.item] = true
                cell.btnValue.titleLabel?.textColor = .black
            }
        }
    }
    
    
}

extension RadioTVCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:lblTitle.intrinsicContentSize.width + 20 , height: 35) // Adjust size accordingly
        }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objData.values?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioBtnCVCell", for: indexPath) as! RadioBtnCVCell
        cell.btnValue.setTitle(objData.values?[indexPath.item] ?? "", for: .normal)
        cell.btnValue.tag = indexPath.item
        cell.btnValue.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)

        return cell
    }
    
 
}
