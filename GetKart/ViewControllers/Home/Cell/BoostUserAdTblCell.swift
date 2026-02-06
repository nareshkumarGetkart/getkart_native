//
//  BoostUserAdTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/01/26.
//

import UIKit
import Kingfisher
import SwiftUI


protocol myAdsBoostDelegate:AnyObject{
    
    func boostedItemId(itemObj:ItemModel)
    
}

class BoostUserAdTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var bgViewTitle:UIView!
    var delegate:myAdsBoostDelegate?
    var listArray:[Any]?
    var navigationController: UINavigationController?
    var section = 0
    var rowIndex = 0
    weak var delegateUpdateList:UPdateListDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "BoostUserAdsHorizontalCell", bundle: nil), forCellWithReuseIdentifier: "BoostUserAdsHorizontalCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.btnClose.setImageTintColor(color: .darkGray)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

extension BoostUserAdTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return listArray?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (listArray?.count ?? 0) == 1{
            return CGSize(width: (self.collectionView.frame.size.width) , height: 130)
        }else{
            return CGSize(width: (self.collectionView.frame.size.width - 11.0) , height: 130)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoostUserAdsHorizontalCell", for: indexPath) as! BoostUserAdsHorizontalCell

        if let obj = listArray?[indexPath.item] as? ItemModel{
            cell.lblName.text = obj.name
            cell.lblLocation.text = obj.address
            cell.lblPrice.text =  "\(Local.shared.currencySymbol) \((obj.price ?? 0.0).formatNumber())"
            
            cell.btnBoostNow.tag = indexPath.item
            cell.btnBoostNow.addTarget(self, action: #selector(boostBtnAction), for: .touchUpInside)
            cell.btnBoostNow.setTitle("Boost \(Local.shared.currencySymbol)\(Int(obj.package?.finalPrice ?? 0))", for: .normal)
            
            if obj.isFeature == true{
                cell.btnBoostNow.isHidden = true
            }else{
                cell.btnBoostNow.isHidden = false
            }
            if let originalImage = UIImage(named: "location-outline") {
                let tintedImage = originalImage.tinted(with: .label)
                cell.imgViewLocIcon.image = tintedImage
            }
            
            let processor = DownsamplingImageProcessor(size: cell.imgViewProduct.bounds.size)
            
            cell.imgViewProduct.kf.setImage(with:  URL(string: obj.image ?? "") ,
                                            placeholder:UIImage(named: "getkartplaceholder"),
                                            options: [
                                                .processor(processor),
                                                .scaleFactor(UIScreen.main.scale)
                                            ])
                        
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
            
            var detailView = ItemDetailView(navController: self.navigationController, itemId:(listArray?[indexPath.item] as? ItemModel)?.id ?? 0, itemObj: (listArray?[indexPath.item] as? ItemModel), slug: (listArray?[indexPath.item] as? ItemModel)?.slug)
//             detailView.returnValue = { [weak self] value in
//                if let obj = value{
//                    self?.listArray?[indexPath.item] = obj
//                    self?.delegateUpdateList?.updateArray(section: self?.section ?? 0, rowIndex: self?.rowIndex ?? 0, arrIndex: indexPath.item, obj: obj)
//                    self?.collectionView.reloadItems(at: [indexPath])
//                }
//            }
            let hostingController = UIHostingController(rootView:detailView )
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
        
    }
    
    
    @objc  func boostBtnAction(_ sender : UIButton){
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            if  let obj = (listArray?[sender.tag] as? ItemModel){
                self.delegate?.boostedItemId(itemObj: obj)
            }
            
            /*if  var obj = (listArray?[sender.tag] as? ItemModel){
                obj.isLiked?.toggle()
                listArray?[sender.tag] = obj
                addToFavourite(itemId:obj.id ?? 0)
                delegateUpdateList?.updateArray(section: section, rowIndex: rowIndex, arrIndex: sender.tag, obj: obj)
                
                self.cllctnView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                
            }*/
        }
    }
    
    
}




