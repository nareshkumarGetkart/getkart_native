//
//  radioTVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/11/25.
//

import UIKit
protocol radioCellTappedDelegate{
    func radioCellTapped(row:Int, clnCell:Int)
}

class RadioTVCell: UITableViewCell {
    @IBOutlet weak var imgImage:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var clnCollectionView:DynamicHeightCollectionView!
    @IBOutlet weak var clnHeight:NSLayoutConstraint!
    
    var objData:CustomFields!
    var del:radioCellTappedDelegate!
    var rowValue:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clnCollectionView.register(UINib(nibName: "RadioBtnCVCell", bundle: .main), forCellWithReuseIdentifier: "RadioBtnCVCell")
        
        
        let alignedFlowLayout = clnCollectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
                alignedFlowLayout?.verticalAlignment = .top
        alignedFlowLayout?.minimumLineSpacing = 0
        alignedFlowLayout?.minimumInteritemSpacing = 0
                alignedFlowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.clnCollectionView.collectionViewLayout.invalidateLayout()
        self.clnCollectionView.layoutIfNeeded()
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func buttonClicked(sender:UIButton)
    {
        print("Tag: ", sender.tag)
        self.del?.radioCellTapped(row: self.rowValue, clnCell: sender.tag)
        
    }
    
    
}

extension RadioTVCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UILabel.textWidth(font: UIFont.Manrope.regular(size: 15).font, text: objData.values?[indexPath.item] ?? "")
        print("\(width)")
        return CGSize(width:width + 20 , height: 45) // Adjust size accordingly
    }*/
    
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
        if objData.arrIsSelected[indexPath.item] == true {
            cell.btnValue.setTitleColor(.orange, for: .normal)
            cell.backView.borderColor = UIColor.orange
        }else {
            cell.btnValue.setTitleColor(.black, for: .normal)
            cell.backView.borderColor = UIColor.black
        }

        return cell
    }
    
 
}
