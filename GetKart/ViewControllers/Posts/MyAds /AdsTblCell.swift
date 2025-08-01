//
//  AdsTblswift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit

class AdsTblCell: UITableViewCell {
    
    @IBOutlet weak var imgVwAds:UIImageView!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblViewCount:UILabel!
    @IBOutlet weak var lblLikeCount:UILabel!
    @IBOutlet weak var btnAdStatus:UIButton!
    @IBOutlet weak var lblItem:UILabel!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var lblBoost:UILabel!
    @IBOutlet weak var imgVwIconSeen:UIImageView!
    @IBOutlet weak var imgVwIconLike:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnAdStatus.layer.cornerRadius = btnAdStatus.frame.height/2.0
        btnAdStatus.clipsToBounds = true
        
        imgVwIconSeen.setImageTintColor(color: .label)
        imgVwIconLike.setImageTintColor(color: .label)

        lblBoost.layer.cornerRadius = 5.0
        lblBoost.clipsToBounds = true
        lblBoost.isHidden = true
        lblBoost.textColor = UIColor.white
        lblBoost.font = UIFont.Manrope.medium(size: 13.0).font

      
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
        
        lblItem.font = UIFont.Manrope.medium(size: 16.0).font
        lblPrice.font = UIFont.Manrope.medium(size: 16.0).font
        lblLikeCount.font = UIFont.Manrope.regular(size: 13.0).font
        lblViewCount.font = UIFont.Manrope.regular(size: 13.0).font
        btnAdStatus.titleLabel?.font = UIFont.Manrope.regular(size: 13.0).font
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureTblCellData(itemObj:ItemModel){
        lblItem.text = itemObj.name
        lblPrice.text =  "\(Local.shared.currencySymbol) \((itemObj.price ?? 0.0).formatNumber())"
        lblLikeCount.text = "Like:\(itemObj.totalLikes ?? 0)"
        lblViewCount.text = "Views:\(itemObj.clicks ?? 0)"
        btnAdStatus.setTitle((itemObj.status ?? "").capitalized, for: .normal)
        lblBoost.isHidden = ((itemObj.isFeature ?? false) == true) ? false : true
        
        switch itemObj.status ?? ""{
            
        case "approved":
            btnAdStatus.setTitleColor(UIColor(hexString: "#32b983"), for: .normal)
            btnAdStatus.backgroundColor = UIColor(hexString: "#e5f7e7")
            break

        case "rejected":
            btnAdStatus.setTitleColor(UIColor(hexString: "#fe0002"), for: .normal)
            btnAdStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
            break
            
        case "inactive":
            btnAdStatus.setTitleColor(UIColor(hexString: "#fe0002"), for: .normal)
            btnAdStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
            break
        case "review":
            btnAdStatus.setTitleColor(UIColor(hexString: "#3e4c63"), for: .normal)
            btnAdStatus.backgroundColor = UIColor(hexString: "#e6eef5")
            btnAdStatus.setTitle(("Under review"), for: .normal)

            break
            
        case "sold out":
            btnAdStatus.setTitleColor(UIColor(hexString: "#ffbb34"), for: .normal)
            btnAdStatus.backgroundColor = UIColor(hexString: "#fff8eb")
            break
       
        case "draft":
            btnAdStatus.setTitleColor(UIColor(hexString: "#3e4c63"), for: .normal)
            btnAdStatus.backgroundColor = UIColor(hexString: "#e6eef5")
        case "expired":
            btnAdStatus.setTitleColor(UIColor(hexString: "#fe0002"), for: .normal)
            btnAdStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
            break

        default:
            break
        }
        imgVwAds.kf.setImage(with:  URL(string: itemObj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        
        DispatchQueue.main.async {
            self.imgVwAds.roundCorners([.topRight,.bottomRight], radius: 10)
            self.imgVwAds.clipsToBounds = true
           // bgView.addShadow()
            self.bgView.layer.borderColor = UIColor.separator.cgColor
            self.bgView.layer.borderWidth = 0.5
            self.bgView.clipsToBounds = true
        }
    }
    
}
