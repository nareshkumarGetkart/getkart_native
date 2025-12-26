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

extension MyAdsVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1
    }
}

class MyAdsVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnScrollView:UIScrollView!
    private  var selectedIndex = 500
    private var apiStatus = ""
    private var page = 1
    private let filters = ["All ads", "Live", "Deactivate","Banner Details", "Under Review","Sold out","Rejected"]
    private var listArray = [ItemModel]()
    private var emptyView:EmptyList?
    private var isDataLoading = true
    private var userBannerArray = [UserBannerModel]()
    
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = .systemYellow
        return refreshControl
    }()
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addObservers()
        topRefreshControl.backgroundColor = .clear
        tblView.refreshControl = topRefreshControl
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Appearance (light/dark mode) has changed
            print("Appearance mode changed: \(traitCollection.userInterfaceStyle == .dark ? "Dark" : "Light")")
            // Update your UI manually here if needed
        }
    }
    
    // MARK: - Setup
       private func setupUI() {
           cnstrntHtNavBar.constant = getNavBarHt
           tblView.register(UINib(nibName: "AdsTblCell", bundle: nil), forCellReuseIdentifier: "AdsTblCell")
           tblView.register(UINib(nibName: "BannerDetailTblCell", bundle: nil), forCellReuseIdentifier: "BannerDetailTblCell")
           tblView.refreshControl = topRefreshControl
           tblView.delegate = self
           tblView.dataSource = self
           DispatchQueue.main.async{
               self.emptyView = EmptyList(frame: self.tblView.bounds)
               self.emptyView?.isHidden = true
               self.emptyView?.lblMsg?.text = ""
               self.emptyView?.imageView?.image = UIImage(named: "no_data_found_illustrator")
               self.tblView.addSubview(self.emptyView!)
               self.emptyView?.delegate = self
           }
           setupFilterButtons()
       }
    
     private func setupFilterButtons() {
            btnScrollView.subviews.forEach { $0.removeFromSuperview() }
            for (index, filter) in filters.enumerated() {
                let btn = UIButton(frame: CGRect(x: (135 * index), y: 10, width: 120, height: 40))
                btn.setTitle(filter, for: .normal)
                btn.tag = index + 500
                btn.layer.cornerRadius = 10
                btn.layer.borderWidth = 1
                btn.layer.borderColor = UIColor.label.cgColor
                btn.setTitleColor(.label, for: .normal)
                btn.titleLabel?.font = UIFont.Manrope.medium(size: 16.0).font
                btn.addTarget(self, action: #selector(filterBtnAction(_:)), for: .touchUpInside)
                btnScrollView.addSubview(btn)
            }
            btnScrollView.contentSize = CGSize(width: CGFloat(135 * filters.count), height: 60)
            updateCoorOfSelectedTab()
            getAdsListApi()
        }
    private func addObservers() {
          NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: .init(NotificationKeys.refreshAdsScreen.rawValue), object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(noInternet(notification:)), name: .init(NotificationKeys.noInternet.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reBannerList), name: .init(NotificationKeys.refreshBannerAdsScreen.rawValue), object: nil)

        
          navigationController?.interactivePopGestureRecognizer?.delegate = self
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

            if apiStatus == "banner details"{
                self.getUserBannersApi()
            }else{
                self.getAdsListApi()
            }
        }
        refreshControl.endRefreshing()
    }
     

    @objc func refreshList(){
        if  self.isDataLoading == false{
            
            refreshMyAds()
        }
    }
    
    
    @objc func reBannerList(){
        if  self.isDataLoading == false{
            
            refreshBannerAds()
        }
    }
    
    func updateCoorOfSelectedTab(){
        
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.backgroundColor = .systemOrange
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.layer.borderColor = UIColor.clear.cgColor
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.clipsToBounds = true
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
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
            //Banner Details
           apiStatus = "banner details"
            
            break
        case 504:
            apiStatus = "review"

            break
        case 505:
            apiStatus = "sold out"
            break
        case 506:
            apiStatus = "rejected"
            break
       
        default:
            break
        }
        
        updateCoorOfSelectedTab()
        
        if apiStatus == "banner details"{
            self.getUserBannersApi()

        }else{
            getAdsListApi()
        }
        
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
    
    
    
    func refreshBannerAds(){
        
      //  if  self.isDataLoading == false{
            selectedIndex = 503
            page = 1
            apiStatus = "banner details"
            if let btn = (self.view.viewWithTag(503) as? UIButton){
               
                if let btnNext = (self.view.viewWithTag(504) as? UIButton){
                    
                    self.btnScrollView.scrollRectToVisible(btnNext.frame, animated: true)
                }

                filterBtnAction(btn)
            }
        //}
    }
    
    
    
    
    //MARK: Api methods
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
            
//            self.emptyView?.isHidden = (self.listArray.count) > 0 ? true : false
//            self.emptyView?.lblMsg?.text = "No Ads Found"
//            self.emptyView?.subHeadline?.text = "There are currently no ads available. Start by creating your first ad now"
            
            if (self.listArray.count) > 0 {
                self.emptyView?.isHidden = true

            }else{
                if self.apiStatus.count == 0{
                    self.emptyView?.btnNavigation?.isHidden = false
                    self.emptyView?.setTitleToBUtton(strTitle: "Start Selling")
                }else{
                    self.emptyView?.btnNavigation?.isHidden = true
                }
                self.emptyView?.isHidden = false
                self.emptyView?.lblMsg?.text = "No Ads Found"
                self.emptyView?.subHeadline?.text = "There are currently no ads available. Start by creating your first ad now"

            }

        }
    }
    
    func getUserBannersApi(){
        
        if self.page == 1{
            self.userBannerArray.removeAll()
            self.listArray.removeAll()
            self.tblView.reloadData()
        }
        
        self.isDataLoading = true
        
        let strUrl = Constant.shared.get_user_banners + "?page=\(page)"

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl,loaderPos: .mid) { (obj:CampaignBannerParse) in
            
            
            if obj.code == 200 {
                

                if obj.data != nil , (obj.data?.data ?? []).count > 0 {
                    self.userBannerArray.append(contentsOf: obj.data?.data ?? [])
                    self.tblView.reloadData()
                }
                                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    
                    self.isDataLoading = false
                    self.page += 1

                })

            }else{
                self.isDataLoading = false

            }
            
            
           
            if (self.userBannerArray.count) > 0 {
                self.emptyView?.isHidden = true

            }else{
                self.emptyView?.setTitleToBUtton(strTitle: "Start Promotion")
                self.emptyView?.isHidden = false
                self.emptyView?.lblMsg?.text = "No Banners Found"
                self.emptyView?.subHeadline?.text = "There are currently no banners available. Start by creating your first banner now"
            }

        }
    }
    
    
}

extension MyAdsVC:EmptyListDelegate{
    
    func navigationButtonClicked() {
        
        if apiStatus == "banner details"{
            let destvc = UIHostingController(rootView: BannerPromotionsView(navigationController:  self.navigationController))
            destvc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destvc, animated: true)
            
        }else{
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                destVC.hidesBottomBarWhenPushed = true
                destVC.popType = .createPost
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        }
        
    }
}


extension MyAdsVC:UITableViewDelegate,UITableViewDataSource{
   
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if apiStatus == "banner details"{
//            return 155
//
//        }
//        return  140
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if apiStatus == "banner details"{
            return userBannerArray.count
        }

        return listArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if apiStatus == "banner details"{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BannerDetailTblCell") as? BannerDetailTblCell else { return UITableViewCell() }
            
            let obj = userBannerArray[indexPath.row]
            cell.imgVwBanner.kf.setImage(with:  URL(string: obj.imagePath ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            
           /* if (obj.isActive ?? 0) == 1{
                cell.lblStatus.text = "Active"
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#e5f7e7")

            }else{
                cell.lblStatus.text = obj.status?.capitalized ?? ""
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#e6eef5")

            }
            */
            if obj.isActive == 1{
                cell.bgViewStatus.isHidden = true
                cell.bgViewActiveStatus.isHidden = false
                cell.bgViewActiveStatus.backgroundColor = UIColor(hexString: "#e5f7e7")

            }else{
                cell.bgViewStatus.isHidden = false
                cell.bgViewActiveStatus.isHidden = true
            }
            cell.lblStatus.text = obj.status?.capitalized ?? ""

            switch obj.status ?? ""{
                
            case "approved", "completed":
                cell.lblStatus.textColor = UIColor(hexString: "#32b983")
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#e5f7e7")
                break

            case "rejected":
                cell.lblStatus.textColor = UIColor(hexString: "#fe0002")
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
                break
                
            case "inactive":
                cell.lblStatus.textColor = UIColor(hexString: "#fe0002")
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#ffe5e6")
                break
            case "review":
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#e6eef5")
                cell.lblStatus.text = "Under review"
                break
                
            case "sold out":
                cell.lblStatus.textColor = UIColor(hexString: "#ffbb34")
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#fff8eb")
                break
           
            case "draft","pending":
                cell.lblStatus.textColor = UIColor(hexString: "#3e4c63")
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#e6eef5")
            case "expired":
               // cell.lblStatus.textColor = UIColor(hexString: "#fe0002")
                cell.bgViewStatus.backgroundColor = UIColor(hexString: "#e6eef5")
                break

            default:
                break
            }
            
            
            cell.lblViewCount.text = "Views: \(obj.analyticsSummary?.totalUniqueViews ?? "")"
            cell.lblLikeCount.text = "No. of Click: \(obj.analyticsSummary?.totalClicks ?? "")"

            DispatchQueue.main.async {
                cell.bgView.roundCorners(corners: [.topRight,.bottomRight,.topLeft,.bottomLeft], radius: 10)
                cell.bgView.layer.borderColor = UIColor.separator.cgColor
                cell.bgView.layer.borderWidth = 0.5
                cell.bgView.clipsToBounds = true
            }
            return cell
            
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdsTblCell") as? AdsTblCell else { return UITableViewCell() }
        cell.configureTblCellData(itemObj: listArray[indexPath.item])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if apiStatus == "banner details"{
            
            let swiftView = BannerAlalyticsView(navigationController: self.navigationController,bannerId: userBannerArray[indexPath.row].id ?? 0)
            let destVC = UIHostingController(rootView: swiftView)
            destVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destVC, animated: true)
      
        }else{
            
            let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId: listArray[indexPath.item].id ?? 0, itemObj: listArray[indexPath.item], isMyProduct:true, slug: listArray[indexPath.item].slug))
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
        }
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
                if isDataLoading == false && (listArray.count > 0 || (apiStatus == "banner details" && userBannerArray.count > 0)){
                    self.isDataLoading = true
                    if apiStatus == "banner details"{
                        getUserBannersApi()
                    }else{
                        getAdsListApi()
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
