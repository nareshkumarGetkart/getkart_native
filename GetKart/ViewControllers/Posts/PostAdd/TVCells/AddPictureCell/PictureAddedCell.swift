//
//  PictureAddedCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/26/25.
//

import UIKit
protocol PictureAddedDelegate {
    func addPictureAction(row:Int)
    func removePictureAction(row:Int, col:Int)
}
class PictureAddedCell: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var clnCollectionView:DynamicHeightCollectionView!
    @IBOutlet weak var btnAddPicture:UIButtonX!
    var arrImagesData:Array<Data> = []
    var rowValue = 0
    var pictureAddDelegate:PictureAddedDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clnCollectionView.register(UINib(nibName: "PictureAddedCVCell", bundle: .main), forCellWithReuseIdentifier: "PictureAddedCVCell")
        
        
        let alignedFlowLayout = clnCollectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
                alignedFlowLayout?.verticalAlignment = .top
        alignedFlowLayout?.minimumLineSpacing = 5
        alignedFlowLayout?.minimumInteritemSpacing = 5
                alignedFlowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        clnCollectionView.isScrollEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clnCollectionView.collectionViewLayout.invalidateLayout()
        self.clnCollectionView.layoutIfNeeded()
    }
}

extension PictureAddedCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (arrImagesData.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureAddedCVCell", for: indexPath) as! PictureAddedCVCell
        cell.btnRemove.tag = indexPath.item
        print("indexPath.item:\(indexPath.item)")
        cell.btnRemove.addTarget(self, action: #selector(removePictureBtnAction(_:)), for: .touchUpInside)
        
        cell.btnAddImage.addTarget(self, action: #selector(addPictureBtnAction(_:)), for: .touchDown)
        
        if indexPath.item < arrImagesData.count {
            cell.imgImage.isHidden = false
            cell.btnRemove.isHidden = false
            cell.btnAddImage.isHidden = true
            if let image = UIImage(data: arrImagesData[indexPath.item]) {
                cell.imgImage.image = image
            }else {
                cell.imgImage.image = nil
            }
            
        }else {
            cell.imgImage.isHidden = true
            cell.btnRemove.isHidden = true
            cell.btnAddImage.isHidden = false
            cell.imgImage.image = nil
        }
            
            
            return cell
        
    }
    
    @objc func addPictureBtnAction(_ sender:UIButton){
        pictureAddDelegate.addPictureAction(row: rowValue)
    }
    
    @objc func removePictureBtnAction(_ sender:UIButton){
        pictureAddDelegate.removePictureAction(row: rowValue, col: sender.tag)
    }
 
}
