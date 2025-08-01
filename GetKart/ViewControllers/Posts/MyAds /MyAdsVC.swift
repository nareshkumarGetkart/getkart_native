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
    private let filters = ["All ads", "Live", "Deactivate", "Under Review","Sold out","Rejected"]
    private var listArray = [ItemModel]()
    private var emptyView:EmptyList?
    private var isDataLoading = true
    
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
           tblView.refreshControl = topRefreshControl
           tblView.delegate = self
           tblView.dataSource = self
           DispatchQueue.main.async{
               self.emptyView = EmptyList(frame: self.tblView.bounds)
               self.emptyView?.isHidden = true
               self.emptyView?.lblMsg?.text = ""
               self.emptyView?.imageView?.image = UIImage(named: "no_data_found_illustrator")
               self.tblView.addSubview(self.emptyView!)
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
            self.getAdsListApi()
        }
        refreshControl.endRefreshing()
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdsTblCell") as? AdsTblCell else { return UITableViewCell() }
        cell.configureTblCellData(itemObj: listArray[indexPath.item])
        
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
