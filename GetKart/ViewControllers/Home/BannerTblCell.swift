//
//  BannerTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 03/03/25.
//

import UIKit

class BannerTblCell: UITableViewCell {
    
    @IBOutlet weak var collctnView:UICollectionView!
    var listArray:[SliderModel]?
    var timer:Timer? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collctnView.register(UINib(nibName: "BannerCell", bundle: nil), forCellWithReuseIdentifier: "BannerCell")
        self.collctnView.delegate = self
        self.collctnView.dataSource = self
        startTimer()
        
    }
    
    
    deinit{
        timer = nil
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func startTimer() {

        timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }

  private  var x = 0

    @objc func scrollAutomatically(_ timer1: Timer) {
        
        if let banner = listArray, banner.count > 0{
            if self.x < banner.count {
                  let indexPath = IndexPath(item: x, section: 0)
                  self.collctnView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                  self.x = self.x + 1
                }else{
                  self.x = 0
                  self.collctnView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                }
        }
    }
}


extension BannerTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArray?.count ?? 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collctnView.bounds.size.width, height: 190)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCell
        if let obj = listArray?[indexPath.item]{
            cell.imgVwBanner.kf.setImage(with:  URL(string: obj.image) , placeholder:UIImage(named: "getkartplaceholder"))
        }
        
        return cell
        
    }
    
}





