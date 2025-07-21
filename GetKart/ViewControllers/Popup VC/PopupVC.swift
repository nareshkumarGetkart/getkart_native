//
//  PopupVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/07/25.
//

import UIKit
import Kingfisher

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
}



class PopupVC: UIViewController {

    @IBOutlet weak var btnOkay:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var txtView:UITextView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var imgVwBanner:UIImageView!
    
    @IBOutlet weak var bgView:UIViewX!


    var respDict:Dictionary<String,Any> = [:]

    //MARK: Controller Life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imgVwBanner.kf.setImage(with: URL(string: respDict["image"] as? String ?? ""))
        lblTitle.text = respDict["title"] as? String ?? ""
        lblSubTitle.text = respDict["subtitle"] as? String ?? ""
        btnOkay.setTitle(respDict["buttonTitle"] as? String ?? "", for: .normal)
        setHTMLTextToLabel(htmlText: respDict["description"] as? String ?? "")
        self.btnClose.isHidden = ((respDict["mandatory_click"] as? Int ?? 0) == 1) ? true : false
        
        btnOkay.backgroundColor = Themes.sharedInstance.themeColor
        btnOkay.layer.cornerRadius = btnOkay.frame.size.height / 2.0
        btnOkay.clipsToBounds = true
        

//        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
//        let theme = AppTheme(rawValue: savedTheme) ?? .system
//        
//        if theme == .dark{
//            bgView.backgroundColor = UIColor(hexString: "#342b1e")
//        }else{
//            bgView.backgroundColor = UIColor(hexString: "#FFF7EA")
//        }
    }
    
    
    func setHTMLTextToLabel(htmlText:String) {
        
        let htmlStringWithCSS = """
               <style>
               body {
                   font-family: Manrope-Regular;
                   font-size: 15px;
               }
               </style>
        \(htmlText)
    
    """
        
        txtView.textColor = .label
        txtView.textColor = .black
        txtView.attributedText = htmlStringWithCSS.htmlAttributedString()
        bgView.backgroundColor = .white
    }
    
    
    //MARK: UIButton Action Methods
    @IBAction func okayButtonAction(_ sender : UIButton){
        self.dismiss(animated: true)
    }
    
    @IBAction func closeButtonAction(_ sender : UIButton){
        self.dismiss(animated: true)
    }
    
    //MARK: Api Methods
    
 }
