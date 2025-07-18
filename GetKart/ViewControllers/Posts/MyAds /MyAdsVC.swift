//
//  MyAdsVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit
import Kingfisher
import SwiftUI
import Alamofire


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
    var isDataLoading = true
    
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemYellow
        return refreshControl
    }()
    
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name:NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil)
        self.topRefreshControl.backgroundColor = .clear
        self.tblView.refreshControl = topRefreshControl
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(noInternet(notification:)),
                                               name:NSNotification.Name(rawValue:NotificationKeys.noInternet.rawValue), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }

    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Appearance (light/dark mode) has changed
            print("Appearance mode changed: \(traitCollection.userInterfaceStyle == .dark ? "Dark" : "Light")")
            
            // Update your UI manually here if needed
        }
    }

    @objc func noInternet(notification:Notification?){
      
        self.isDataLoading = false
        AlertView.sharedManager.showToast(message: "No internet connection")

    }
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !AppDelegate.sharedInstance.isInternetConnected{
             isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
      
        }else if !isDataLoading {
            self.isDataLoading = true
            page = 1
            self.getAdsListApi()
        }
        refreshControl.endRefreshing()
    }
     
    
    func addButtonsToScrollView(){
            
        for index in 0..<filters.count{
            
            let btn = UIButton(frame: CGRect(x: ((120 + 15) * index)  , y: 10, width: 120, height: 40))
            btn.setTitle(filters[index], for: .normal)
            btn.layer.cornerRadius = 10.0
            btn.layer.borderColor = UIColor.label.cgColor
            btn.layer.borderWidth = 1.0
            btn.setTitleColor( UIColor.label, for: .normal)
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
    
    @objc func refreshList(){
        if  self.isDataLoading == false{
            
            refreshMyAds()
        }
    }
    
    
    
    func updateCoorOfSelectedTab(){
        
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.backgroundColor = .systemOrange
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.layer.borderColor = UIColor.clear.cgColor
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.clipsToBounds = true
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.setTitleColor(.white, for: .normal)
    }
    
    @objc func filterBtnAction(_ btn : UIButton){
        
      
        selectedIndex = btn.tag
        self.isDataLoading = true

        for index in 0..<filters.count{
            
            (self.view.viewWithTag(500 + index) as? UIButton)?.backgroundColor = .clear
            (self.view.viewWithTag(500 + index) as? UIButton)?.layer.borderColor = UIColor.label.cgColor
            (self.view.viewWithTag(500 + index) as? UIButton)?.layer.borderWidth = 1.0
            (self.view.viewWithTag(500 + index) as? UIButton)?.setTitleColor( UIColor.label, for: .normal)
            (self.view.viewWithTag(500 + index) as? UIButton)?.clipsToBounds = true
        }

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
        if  self.isDataLoading == false{
            selectedIndex = 500
            page = 1
            apiStatus = ""
            if let btn = (self.view.viewWithTag(500) as? UIButton){
                filterBtnAction(btn)
            }
        }
    }
    
    //Api methods
    func getAdsListApi(){
        
        
        if self.page == 1{
            self.listArray.removeAll()
            self.tblView.reloadData()
        }

        let strUrl = Constant.shared.my_items + "?status=\(apiStatus)&page=\(page)"
        self.isDataLoading = true
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl,loaderPos: .mid) { (obj:ItemParse) in
            
            
            if obj.code == 200 {
                

                if obj.data != nil , (obj.data?.data ?? []).count > 0 {
                    self.listArray.append(contentsOf: obj.data?.data ?? [])
                    self.tblView.reloadData()
                }
                                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    
                    self.isDataLoading = false
                    self.page += 1

                })

            }else{
                self.isDataLoading = false

            }
            
            self.emptyView?.isHidden = (self.listArray.count) > 0 ? true : false
            self.emptyView?.lblMsg?.text = "No Ads Found"
            self.emptyView?.subHeadline?.text = "There are currently no ads available. Start by creating your first ad now"

        }
    }
    
    func postDraftAds(post:ItemModel,index:Int){
        
        let params = ["id":post.id ?? 0]
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
                            destvc.country =  post.country ?? ""
                            destvc.state =  post.state ?? ""
                            destvc.latitude = "\(post.latitude ?? 0.0)"
                            destvc.longitude = "\(post.longitude ?? 0.0)"
                            self.navigationController?.pushViewController(destvc, animated: true)
                        }
                    }
                }
            }
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
        cell.lblPrice.text =  "\(Local.shared.currencySymbol) \((obj.price ?? 0.0).formatNumber())"
        cell.lblLikeCount.text = "Like:\(obj.totalLikes ?? 0)"
        cell.lblViewCount.text = "Views:\(obj.clicks ?? 0)"
        cell.btnAdStatus.setTitle((obj.status ?? "").capitalized, for: .normal)
        cell.btnAdPost.isHidden = true
        cell.lblBoost.isHidden = ((obj.isFeature ?? false) == true) ? false : true
        
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
        case "expired":
            cell.btnAdStatus.setTitleColor(UIColor(hexString: "#fe0002"), for: .normal)
            cell.btnAdStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
            break

        default:
            break
        }
        cell.imgVwAds.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        
        DispatchQueue.main.async {
            cell.imgVwAds.roundCorners([.topRight,.bottomRight], radius: 10)
            cell.imgVwAds.clipsToBounds = true
            cell.bgView.addShadow()
            cell.bgView.layer.borderColor = UIColor.separator.cgColor
            cell.bgView.layer.borderWidth = 0.5
            cell.bgView.clipsToBounds = true
        }

        cell.btnAdPost.tag = indexPath.item
        cell.btnAdPost.addTarget(self, action: #selector(addPostBtnAction(_ : )), for: .touchUpInside)
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId: listArray[indexPath.item].id ?? 0, itemObj: listArray[indexPath.item], isMyProduct:true, slug: listArray[indexPath.item].slug))
        hostingController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
           // print("up")
            if scrollView == tblView{
                return
            }
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 70)
        {
            if scrollView == tblView{
                if isDataLoading == false && listArray.count > 0{
                    self.isDataLoading = true
                    getAdsListApi()
                }
            }
        }
    }
    
    
    //MARK: Selector Methods
    @objc func addPostBtnAction(_ btn:UIButton){
        
        self.postDraftAds( post: listArray[btn.tag], index: btn.tag)
        
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
