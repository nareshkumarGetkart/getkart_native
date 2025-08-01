//
//  AdsPreviewBannerImageVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/08/25.
//

import UIKit
import SwiftyGif

class AdsPreviewBannerImageItemVC: UIViewController {
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var gifImageview:UIImageView!
    @IBOutlet weak var bannerImageview:UIImageView!
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnBack.setImageColor(color: .label)
        lblTitle.text = "Item description"
        bannerImageview.image = image
        bannerImageview.layer.cornerRadius = 5.0
        bannerImageview.clipsToBounds = true
        do{
            try  self.gifImageview.setGifImage(UIImage(gifName: "handPoint"), loopCount: -1)
            self.gifImageview.startAnimating()

        }catch{
            
        }
    }
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    

}
