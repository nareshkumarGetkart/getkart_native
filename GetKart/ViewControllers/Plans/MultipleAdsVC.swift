//
//  MultipleAdsVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit
import FittedSheets
import PhonePePayment
import SwiftUI

class MultipleAdsVC: UIViewController {
    
    @IBOutlet weak var lblHeader:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var btnInfo:UIButton!
    @IBOutlet weak var btnHowItWorks:UIButton!


    var planListArray = [PlanModel]()
    var selectedIndex = -1
    var callbackSelectedPlans: ((_ selPlanObj: PlanModel) -> Void)?

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "PackageAdsCell", bundle: nil), forCellReuseIdentifier: "PackageAdsCell")
        lblHeader.text = planListArray.first?.name ?? ""
        lblSubTitle.text = planListArray.first?.title ?? ""
        lblTitle.text = "Package availability - \(planListArray.first?.duration ?? "") days"
        btnClose.setImageTintColor(color: .label)
        btnInfo.setImageTintColor(color: .label)
        
        if  let obj = planListArray.first{
            if (obj.type == .itemListing){
                btnHowItWorks.isHidden = true
            }
        }
    }
    
    //MARK: UIbutton Action Methods
    @IBAction func closeBtnAction(_ sender:UIButton){
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func infoTapped(sender: UIButton) {
        showTooltip(
            message: "Package Validity – Each purchased package comes with a defined validity period. Please use the package within this time frame to avoid expiration.",
            anchorView: sender
        )
    }
    
    @IBAction func howItWorks(sender: UIButton) {
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
        if let url = URL(string: Constant.shared.BOOSTEDADS_DEMO){
            let vc = UIHostingController(rootView:  PreviewURL(fileURLString:Constant.shared.BOOSTEDADS_DEMO,istoApplyPadding:true))
            AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)

        }
    }

}

extension MultipleAdsVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return planListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageAdsCell") as! PackageAdsCell
        
        let obj = planListArray[indexPath.row]
        cell.lblAmount.text = "\(Local.shared.currencySymbol)\(obj.finalPrice ?? "0")"
        cell.lblNumberOfAds.text = "\(obj.itemLimit ?? "") Ad"
        
        if (obj.discountInPercentage ?? "0") == "0"{
            cell.lblDiscountPercentage.text = ""
            cell.lblDiscountPercentage.isHidden = true
            cell.lblOriginalAmt.attributedText = NSAttributedString(string: "")

        }else{
            cell.lblDiscountPercentage.text = "\(obj.discountInPercentage ?? "0")% Savings"
            cell.lblDiscountPercentage.isHidden = false
            cell.lblOriginalAmt.attributedText = "\(Local.shared.currencySymbol)\(obj.price ?? "0")".setStrikeText(color: .gray)
        }
    
        
        if selectedIndex == indexPath.row{
            cell.bgView.layer.borderColor = UIColor(hexString: "#FF9900").cgColor
        }else{
            cell.bgView.layer.borderColor = UIColor.gray.cgColor
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tblView.reloadData()
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        callbackSelectedPlans?(planListArray[indexPath.row])

        // self.createPhonePayOrder(package_id: obj.id ?? 0)
    }
    /*
    func getPaymentSettings(){
        let params:Dictionary<String, Any> = [:]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.getPaymentSettings, param: nil, methodType: .get,showLoader:true) { [weak self] responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        if let PhonePeDict = dataDict["PhonePe"] as? Dictionary<String, Any>  {
                            self?.api_key = PhonePeDict["api_key"] as? String ?? ""
                            self?.merchantId = PhonePeDict["merchent_id"] as? String ?? ""
                            
                            var flowId = ""
                            let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                            if objLoggedInUser.id != nil {
                                flowId = "\(objLoggedInUser.id ?? 0)"
                            }
                            
                            if devEnvironment == .live {
                                self?.ppPayment = PPPayment(environment: .production,
                                                          flowId: flowId,
                                                       merchantId: self?.merchantId ?? "",
                                                       enableLogging: false)
                            }else {
                                self?.ppPayment = PPPayment(environment: .sandbox,
                                                          flowId: flowId,
                                                      merchantId: self?.merchantId ?? "", enableLogging: true)
                            }
                            
                        }
                    }
                    
                    
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    func createPhonePayOrder(package_id:Int){
        
        let params:Dictionary<String, Any> = ["package_id":package_id,"payment_method":"PhonePe", "platform_type":"app"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.paymentIntent, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        if let payment_intentDict = dataDict["payment_intent"] as? Dictionary<String, Any> {
                            if let payment_gateway_response = payment_intentDict["payment_gateway_response"] as? Dictionary<String, Any>  {
                                let orderId = payment_gateway_response["orderId"] as? String ?? ""
                                let token  = payment_gateway_response["token"] as? String ?? ""
                                self?.startCheckoutPhonePay(orderId: orderId, token: token)
                            }
                        }
                    }
                   
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    
    func startCheckoutPhonePay(orderId: String, token:String){
        let appSchema = "Getkart IOS App"
        ppPayment.startCheckoutFlow(merchantId: merchantId,
                                    orderId: orderId,
                                    token: token,
                                    appSchema: appSchema,
                                    on: self) { _, state in
                    print(state)
        }
    }
    */
}
      

final class PaddingLabel: UILabel {

    var padding = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let inset = CGSize(
            width: size.width - padding.left - padding.right,
            height: size.height - padding.top - padding.bottom
        )
        let textSize = super.sizeThatFits(inset)
        return CGSize(
            width: textSize.width + padding.left + padding.right,
            height: textSize.height + padding.top + padding.bottom
        )
    }
}



/*func showInfoToast(message: String, anchorView: UIView) {
    guard let window = UIApplication.shared.windows.first else { return }

    let toastLabel = PaddingLabel()
    toastLabel.text = message
    toastLabel.textColor = .white
    toastLabel.font = UIFont.systemFont(ofSize: 14)
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.9)
    toastLabel.numberOfLines = 0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    toastLabel.padding = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
    toastLabel.alpha = 0

    let maxWidth = window.frame.width - 40
    toastLabel.preferredMaxLayoutWidth = maxWidth

    // ⚠️ SET WIDTH FIRST
    toastLabel.frame = CGRect(
        x: 20,
        y: 0,
        width: maxWidth,
        height: CGFloat.greatestFiniteMagnitude
    )

    // ✅ NOW height will expand
    let size = toastLabel.sizeThatFits(
        CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
    )

    let anchorFrame = anchorView.convert(anchorView.bounds, to: window)

    toastLabel.frame = CGRect(
        x: (window.frame.width - size.width) / 2,
        y: anchorFrame.minY - size.height - 12,
        width: size.width,
        height: size.height
    )

    window.addSubview(toastLabel)

    UIView.animate(withDuration: 0.25) {
        toastLabel.alpha = 1
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        UIView.animate(withDuration: 0.25, animations: {
            toastLabel.alpha = 0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}
*/

func showTooltip(message: String, anchorView: UIView) {
    guard let window = UIApplication.shared.windows.first else { return }
    
    let tooltip = TooltipBubbleView(
        text: message,
        maxWidth: window.bounds.width - 40
    )
    
    let anchorFrame = anchorView.convert(anchorView.bounds, to: window)
    
    tooltip.frame.origin = CGPoint(
        x: (window.bounds.width - tooltip.frame.width) / 2,
        y: anchorFrame.minY - tooltip.frame.height - 6
    )
    
    tooltip.alpha = 0
    window.addSubview(tooltip)
    
    UIView.animate(withDuration: 0.25) {
        tooltip.alpha = 1
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        UIView.animate(withDuration: 0.25, animations: {
            tooltip.alpha = 0
        }) { _ in
            tooltip.removeFromSuperview()
        }
    }
}

final class TooltipBubbleView: UIView {

    private let arrowHeight: CGFloat = 8
    private let arrowWidth: CGFloat = 16
    private let cornerRadius: CGFloat = 14
    private let label = PaddingLabel()
    private let shapeLayer = CAShapeLayer()

    init(text: String, maxWidth: CGFloat) {
        super.init(frame: .zero)
        backgroundColor = .clear

        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.padding = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

        let textSize = label.sizeThatFits(
            CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        )

        frame = CGRect(
            x: 0,
            y: 0,
            width: textSize.width,
            height: textSize.height + arrowHeight
        )

        label.frame = CGRect(
            x: 0,
            y: 0,
            width: textSize.width,
            height: textSize.height
        )

        addSubview(label)
        layer.insertSublayer(shapeLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawBubble()
    }

    private func drawBubble() {
        let path = UIBezierPath()

        let bubbleHeight = bounds.height - arrowHeight

        // Top-left
        path.move(to: CGPoint(x: cornerRadius, y: 0))

        // Top
        path.addLine(to: CGPoint(x: bounds.width - cornerRadius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: bounds.width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )

        // Right
        path.addLine(to: CGPoint(x: bounds.width, y: bubbleHeight - cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: bounds.width - cornerRadius, y: bubbleHeight - cornerRadius),
            radius: cornerRadius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )

        // Arrow
        path.addLine(to: CGPoint(x: bounds.midX + arrowWidth / 2, y: bubbleHeight))
        path.addLine(to: CGPoint(x: bounds.midX, y: bubbleHeight + arrowHeight))
        path.addLine(to: CGPoint(x: bounds.midX - arrowWidth / 2, y: bubbleHeight))

        // Bottom-left
        path.addLine(to: CGPoint(x: cornerRadius, y: bubbleHeight))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: bubbleHeight - cornerRadius),
            radius: cornerRadius,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )

        // Left
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi,
            endAngle: -.pi / 2,
            clockwise: true
        )

        path.close()

        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.9).cgColor
    }
}
