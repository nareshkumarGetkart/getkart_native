//
//  radioTVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/11/25.
//

import UIKit
import WebKit
protocol radioCellTappedDelegate{
    func radioCellTapped(row:Int, clnCell:Int)
}

class RadioTVCell: UITableViewCell {
    @IBOutlet weak var iconImgWebView:WKWebView!
    @IBOutlet weak var imgImage:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var clnCollectionView:DynamicHeightCollectionView!
    @IBOutlet weak var clnHeight:NSLayoutConstraint!
    @IBOutlet weak var lblErrorMsg:UILabel!
    var objData:CustomField?
    var del:radioCellTappedDelegate?
    var rowValue:Int = 0
    @IBOutlet weak var imgViewBg:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgViewBg.layer.cornerRadius = 5.0
        imgViewBg.clipsToBounds = true
        
        
        clnCollectionView.register(UINib(nibName: "RadioBtnCVCell", bundle: .main), forCellWithReuseIdentifier: "RadioBtnCVCell")
        clnCollectionView.register(UINib(nibName: "CheckBoxCVCell", bundle: .main), forCellWithReuseIdentifier: "CheckBoxCVCell")
        
        let alignedFlowLayout = clnCollectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
                alignedFlowLayout?.verticalAlignment = .top
        alignedFlowLayout?.minimumLineSpacing = 0
        alignedFlowLayout?.minimumInteritemSpacing = 0
                alignedFlowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
    }

    
    func reloadCollectionView(){
        self.clnCollectionView.collectionViewLayout.invalidateLayout()
        self.clnCollectionView.layoutIfNeeded()
        self.clnCollectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clnCollectionView.collectionViewLayout.invalidateLayout()
        self.clnCollectionView.layoutIfNeeded()
    }
    
    func configure(with obj:CustomField?) {
        self.objData = obj
        self.clnCollectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func buttonClicked(sender:UIButton)
    {
        print("Tag: ", sender.tag)
        
//        if objData?.value?.contains(objData?.values?[sender.tag]) == true{
//            objData?.values?[sender.tag] = ""
//            self.clnCollectionView.reloadItems(at: [IndexPath(row:  sender.tag, section: 0)])
//        }
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
        return objData?.values?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if objData?.type == .checkbox {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CheckBoxCVCell", for: indexPath) as! CheckBoxCVCell
            cell.btnValue.setTitle("", for: .normal)
            cell.btnValue.setTitle(objData?.values?[indexPath.item] ?? "", for: .normal)
           // print("CheckBox objData?.values?[indexPath.item] : ",objData?.values?[indexPath.item] ?? "")
            cell.btnValue.tag = indexPath.item
            cell.btnValue.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            if objData?.value?.contains(objData?.values?[indexPath.item]) == true {
                cell.imgSelect.image = UIImage.init(systemName: "checkmark")
                cell.imgSelect.setImageTintColor(color: UIColor.systemOrange)
                cell.btnValue.setTitleColor(.orange, for: .normal)
                cell.backView.borderColor = UIColor.orange
            }else {
                cell.imgSelect.image = UIImage.init(systemName: "plus")
                cell.imgSelect.setImageTintColor(color: UIColor.label)
                cell.btnValue.setTitleColor(.label, for: .normal)
                cell.backView.borderColor = UIColor.label
            }
            
            return cell
        }else if objData?.type == .radio {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioBtnCVCell", for: indexPath) as! RadioBtnCVCell
            cell.btnValue.setTitle("", for: .normal)
            
            cell.btnValue.setTitle(objData?.values?[indexPath.item] ?? "", for: .normal)
          //  print("Radio objData?.values?[indexPath.item] : ",objData?.values?[indexPath.item] ?? "")
            cell.btnValue.tag = indexPath.item
            cell.btnValue.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
           
            if objData?.value?.contains(objData?.values?[indexPath.item]) == true {
                cell.btnValue.setTitleColor(.orange, for: .normal)
                cell.backView.borderColor = UIColor.orange
            }else {
                cell.btnValue.setTitleColor(.label, for: .normal)
                cell.backView.borderColor = UIColor.label
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
 
}
