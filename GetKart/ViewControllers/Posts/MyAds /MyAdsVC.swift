//
//  MyAdsVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit
import Kingfisher
import SwiftUI


class MyAdsVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnScrollView:UIScrollView!
    private  var selectedIndex = 500
    private var apiStatus = ""
    private var page = 1
    private  let filters = ["All ads", "Live", "Deactivate", "Under Review","Sold out","Rejected"]
    
    var listArray = [ItemModel]()
    private var emptyView:EmptyList?
    var isClicked = false
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "AdsTblCell", bundle: nil), forCellReuseIdentifier: "AdsTblCell")
        
        DispatchQueue.main.async{
            self.emptyView = EmptyList(frame: CGRect(x: 0, y: 0, width:  self.tblView.frame.size.width, height:  self.tblView.frame.size.height))
            self.tblView.addSubview(self.emptyView!)
            self.emptyView?.isHidden = true
            self.emptyView?.lblMsg?.text = ""
            self.emptyView?.imageView?.image = UIImage(named: "no_data_found_illustrator")
        }
        
        addButtonsToScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isClicked{
            isClicked = false
            getAdsListApi()
        }
    }
    
    func addButtonsToScrollView(){
            
        for index in 0..<filters.count{
            
            let btn = UIButton(frame: CGRect(x: ((120 + 15) * index)  , y: 10, width: 120, height: 40))
            btn.setTitle(filters[index], for: .normal)
            btn.layer.cornerRadius = 10.0
            btn.layer.borderColor = UIColor.black.cgColor
            btn.layer.borderWidth = 1.0
            btn.setTitleColor( UIColor.black, for: .normal)
            btn.titleLabel?.font = UIFont.Manrope.medium(size: 16.0).font
            btn.clipsToBounds = true
            btn.tag = index + 500
            btn.addTarget(self, action: #selector(filterBtnAction(_ : )), for: .touchUpInside)
            btnScrollView.addSubview(btn)
            
        }
        
        btnScrollView.contentSize.width   = CGFloat(135 * filters.count) + 50
        updateCoorOfSelectedTab()
        getAdsListApi()
    }
    
    
    func updateCoorOfSelectedTab(){
        
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.backgroundColor = .systemOrange
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.layer.borderColor = UIColor.clear.cgColor
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.clipsToBounds = true
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.setTitleColor(.white, for: .normal)
    }
    
    @objc func filterBtnAction(_ btn : UIButton){
        
        selectedIndex = btn.tag
        
        for index in 0..<filters.count{
            
            (self.view.viewWithTag(500 + index) as? UIButton)?.backgroundColor = .clear
            (self.view.viewWithTag(500 + index) as? UIButton)?.layer.borderColor = UIColor.black.cgColor
            (self.view.viewWithTag(500 + index) as? UIButton)?.layer.borderWidth = 1.0
            (self.view.viewWithTag(500 + index) as? UIButton)?.setTitleColor( UIColor.black, for: .normal)
            (self.view.viewWithTag(500 + index) as? UIButton)?.clipsToBounds = true

        }
        
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.backgroundColor = .systemOrange
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.layer.borderColor = UIColor.clear.cgColor
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.clipsToBounds = true
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.setTitleColor(.white, for: .normal)


        page = 1
        
        
        switch btn.tag{
            
        case 500:
            apiStatus = ""
            break
        case 501:
            apiStatus = "approved"

            break
        case 502:
            apiStatus = "inactive"

            break
        case 503:
            apiStatus = "review"

            break
        case 504:
            apiStatus = "sold out"
            break
        case 505:
            apiStatus = "rejected"
            break
       
        default:
            break
        }
        
        updateCoorOfSelectedTab()
        
        getAdsListApi()
        
    }

    
    func refreshMyAds(){
        selectedIndex = 500
        page = 1
        apiStatus = ""
        if let btn = (self.view.viewWithTag(500) as? UIButton){
            filterBtnAction(btn)
        }
    }
    
    //Api methods
    func getAdsListApi(){
        
        
        let strUrl = Constant.shared.my_items + "?status=\(apiStatus)&page=\(page)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:ItemParse) in
            
            if self.page == 1{
                self.listArray.removeAll()
                self.tblView.reloadData()

            }
            if obj.data != nil {
                self.listArray.append(contentsOf: obj.data?.data ?? [])
                self.tblView.reloadData()
            }
            
            self.emptyView?.isHidden = (self.listArray.count) > 0 ? true : false
            self.emptyView?.lblMsg?.text = "No Ads Found"
            self.emptyView?.subHeadline?.text = "There are currently no ads available. Start by creating your first ad now"

        }

    }
}



extension MyAdsVC:UITableViewDelegate,UITableViewDataSource{
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return listArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdsTblCell") as! AdsTblCell
        
        
        let obj = listArray[indexPath.item]
        cell.lblItem.text = obj.name
        cell.lblPrice.text =  "\(Local.shared.currencySymbol) \(obj.price ?? 0)"
        cell.lblLikeCount.text = "Like:\(obj.totalLikes ?? 0)"
        cell.lblViewCount.text = "Views:\(obj.clicks ?? 0)"
        cell.btnAdStatus.setTitle((obj.status ?? "").capitalized, for: .normal)
        cell.btnAdPost.isHidden = true
        
        switch obj.status ?? ""{
            
        case "approved":
            cell.btnAdStatus.setTitleColor(UIColor(hexString: "#32b983"), for: .normal)
            cell.btnAdStatus.backgroundColor = UIColor(hexString: "#e5f7e7")
            break

        case "rejected":
            cell.btnAdStatus.setTitleColor(UIColor(hexString: "#fe0002"), for: .normal)
            cell.btnAdStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
            break
            
        case "inactive":
            cell.btnAdStatus.setTitleColor(UIColor(hexString: "#fe0002"), for: .normal)
            cell.btnAdStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
            break
        case "review":
            cell.btnAdStatus.setTitleColor(UIColor(hexString: "#3e4c63"), for: .normal)
            cell.btnAdStatus.backgroundColor = UIColor(hexString: "#e6eef5")
            cell.btnAdStatus.setTitle(("Under review"), for: .normal)

            break
            
        case "sold out":
            cell.btnAdStatus.setTitleColor(UIColor(hexString: "#ffbb34"), for: .normal)
            cell.btnAdStatus.backgroundColor = UIColor(hexString: "#fff8eb")
            break
       
        case "draft":
            cell.btnAdStatus.setTitleColor(UIColor(hexString: "#3e4c63"), for: .normal)
            cell.btnAdStatus.backgroundColor = UIColor(hexString: "#e6eef5")
            cell.btnAdPost.isHidden = false

        default:
            break
        }
        cell.imgVwAds.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        
        DispatchQueue.main.async {
            cell.imgVwAds.roundCorners([.topRight,.bottomRight], radius: 10)

        }

        cell.btnAdPost.tag = indexPath.item
        cell.btnAdPost.addTarget(self, action: #selector(addPostBtnAction(_ : )), for: .touchUpInside)
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isClicked = true

        let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId: listArray[indexPath.item].id ?? 0, itemObj: listArray[indexPath.item], isMyProduct:true, slug: listArray[indexPath.item].slug))
        hostingController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    //MARK: Selector Methods
    @objc func addPostBtnAction(_ btn:UIButton){
        
        self.postDraftAds( post: listArray[btn.tag], index: btn.tag)
        
    }
    
    
    func postDraftAds(post:ItemModel,index:Int){
        
        let params = ["id":post.id ?? 0]
       // let strURl = Constant.shared.post_draft_item //+ "?id=\(post.id ?? 0)"
        URLhandler.sharedinstance.makeCall(url:Constant.shared.post_draft_item , param: params, methodType:.post, showLoader: true) { responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                        do {
                            let item = try JSONDecoder().decode(SingleItemParse.self, from: jsonData)
                            if let itemObj = item.data?.first {
                             
                                self.listArray[index] = itemObj
                                self.tblView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                            }
                        }catch {
                            
                        }
                        
                    } else {
                        print("Something is wrong while converting dictionary to JSON data.")
                        
                    }
                    
                    
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                    
                    if (post.city?.count ?? 0) > 0 && (post.categoryID ?? 0) > 0 {
                        
                        if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
                            destvc.hidesBottomBarWhenPushed = true
                            destvc.categoryId = post.categoryID ?? 0
                            destvc.categoryName = post.category?.name ?? ""
                            destvc.city = post.city ?? ""
                            self.navigationController?.pushViewController(destvc, animated: true)
                        }
                    }
                }
            }
        }
        
    }
    
}




extension UIImageView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
