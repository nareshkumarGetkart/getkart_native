//
//  HomeVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI
import Kingfisher

class HomeVC: UIViewController, LocationSelectedDelegate {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var btnLocation:UIButton!
    @IBOutlet weak var loaderBgView:UIView!
    @IBOutlet weak var cnstrntLoaderHt:NSLayoutConstraint!

    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemYellow
        return refreshControl
    }()
    
    private var homeVModel:HomeViewModel?

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnLocation.layer.cornerRadius = 8.0
        btnLocation.backgroundColor = .white
        btnLocation.clipsToBounds = true
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 200
        updateTolocation()
        registerCells()
        homeVModel = HomeViewModel()
        homeVModel?.delegate = self
        homeVModel?.getProductListApi()
        self.topRefreshControl.backgroundColor = .clear
        tblView.refreshControl = topRefreshControl
        
        NotificationCenter.default.addObserver(self,selector:
                                                #selector(handleLocationSelected(_:)),
                                               name:NSNotification.Name(rawValue:NotiKeysLocSelected.homeNewLocation.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self,selector:
                                                #selector(noInternet(notification:)),
                                               name:NSNotification.Name(rawValue:NotificationKeys.noInternet.rawValue),
                                               object: nil)
    }
    
    
    @objc func handleLocationSelected(_ notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String: Any]
        {
            let city = userInfo["city"] as? String ?? ""
            let state = userInfo["state"] as? String ?? ""
            let country = userInfo["country"] as? String ?? ""
            let latitude = userInfo["latitude"] as? String ?? ""
            let longitude = userInfo["longitude"] as? String ?? ""
            let locality = userInfo["locality"] as? String ?? ""
            
            print("Received Location: \(city), \(state), \(country)")
                        
            homeVModel?.page = 1
            homeVModel?.itemObj?.data = nil
            homeVModel?.featuredObj = nil
            self.tblView.reloadData()
            
            homeVModel?.city = city
            homeVModel?.country = country
            homeVModel?.state = state
            homeVModel?.latitude = latitude
            homeVModel?.longitude = longitude

            homeVModel?.getProductListApi()
            homeVModel?.getFeaturedListApi()
            var locStr = city
            
            if state.count > 0 {
                locStr =  locStr.count > 0 ? locStr + ", " + state : state
            }
            
            if country.count > 0 {
                locStr =  locStr.count > 0 ? locStr + ", " + country : country
            }
            
            if locStr.count == 0 {
                locStr = "All Countries"
            }
            self.lblAddress.text = locStr
            // Handle UI update or data save
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !AppDelegate.sharedInstance.isInternetConnected{
            homeVModel?.isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
        
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clear caches, release unnecessary memory
        ImageCache.default.clearMemoryCache()
    }

    
    
    private func updateTolocation(){
        
        let city = Local.shared.getUserCity()
        let state = Local.shared.getUserState()
        let country = Local.shared.getUserCountry()
        var locStr = city
        if state.count > 0 {
            locStr =  locStr.count > 0 ? locStr + ", " + state : state
        }
        if country.count > 0 {
            locStr =  locStr.count > 0 ? locStr + ", " + country : "All \(country)"
        }
        
        if locStr.count == 0 {
            locStr = "All Countries"
        }
        
        self.lblAddress.text = locStr
    }
    func registerCells(){
        tblView.register(UINib(nibName: "HomeTblCell", bundle: nil), forCellReuseIdentifier: "HomeTblCell")
        tblView.register(UINib(nibName: "HomeHorizontalCell", bundle: nil), forCellReuseIdentifier: "HomeHorizontalCell")
        tblView.register(UINib(nibName: "BannerTblCell", bundle: nil), forCellReuseIdentifier: "BannerTblCell")        
    }
    
    
    func scrollToTop() {
        DispatchQueue.main.async {
            // scroll code here
            let topIndex = IndexPath(row: 0, section: 0)
            if self.tblView?.numberOfRows(inSection: 0) ?? 0 > 0 {
                self.tblView?.scrollToRow(at: topIndex, at: .top, animated: true)
            }
        }
    }
    
    
    @objc func noInternet(notification:Notification?){
      
        homeVModel?.isDataLoading = false
        AlertView.sharedManager.showToast(message: "No internet connection")

    }
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
      
        if !AppDelegate.sharedInstance.isInternetConnected{
            homeVModel?.isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
      
        }else if !(homeVModel?.isDataLoading ?? false) {
            homeVModel?.page = 1
            homeVModel?.getProductListApi()
            homeVModel?.getSliderListApi()
            homeVModel?.getFeaturedListApi()
        }
        refreshControl.endRefreshing()
    }
     
    //MARK: UIButton Action
    
    @IBAction func locationBtnAction(_ sender : UIButton){
        var rootView = CountryLocationView(popType: .home, navigationController: self.navigationController)
        rootView.delLocationSelected = self
           let vc = UIHostingController(rootView:rootView)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    
}
    
    @IBAction func searchBtnAction(_ sender : UIButton){
        let hostingController = UIHostingController(rootView: SearchProductView(navigation:self.navigationController)) // Wrap in UIHostingController
        hostingController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @IBAction func micBtnAction(_ sender : UIButton){
        
        
    }
    
    @IBAction func filterBtnAction(_ sender : UIButton){
        
        let hostingController = UIHostingController(rootView: SearchProductView(navigation:self.navigationController,navigateToFilterScreen: true))
        hostingController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hostingController, animated: false)
    }
    
    
    @IBAction func logoBtnAction(_ sender : UIButton){
        
        
    }

    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String){

        homeVModel?.page = 1
        homeVModel?.itemObj?.data = nil
        homeVModel?.featuredObj = nil
        self.tblView.reloadData()
        
        homeVModel?.city = city
        homeVModel?.country = country
        homeVModel?.state = state
        homeVModel?.latitude = latitude
        homeVModel?.longitude = longitude
        homeVModel?.getProductListApi()
        homeVModel?.getFeaturedListApi()
        var locStr = city
        
        if state.count > 0 {
            locStr =  locStr.count > 0 ? locStr + ", " + state : state
        }
        
        if country.count > 0 {
            locStr =  locStr.count > 0 ? locStr + ", " + country : country
        }
        
        if locStr.count == 0 {
            locStr = "All Countries"
        }
        self.lblAddress.text = locStr
    }
}

extension HomeVC:FilterSelected{
    
    
    func filterSelectectionDone(dict:Dictionary<String,Any>, dataArray:Array<CustomField>, strCategoryTitle:String) {
        print(dict)
        
        homeVModel?.page = 1
        homeVModel?.itemObj?.data = nil
        self.tblView.reloadData()
        homeVModel?.getProductListApi()
        
        if let  city = dict["city"] as? String,let  state = dict["state"] as? String,let  country = dict["country"] as? String{
            var locStr = city
            if state.count > 0 {
                locStr =  locStr.count > 0 ? locStr + ", " + state : state
            }
            
            if country.count > 0 {
                locStr =  locStr.count > 0 ? locStr + ", " + country : country
            }
            
            if locStr.count == 0 {
                locStr = "All Countries"
            }
            self.lblAddress.text = locStr
        }
    }
}


extension HomeVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return (homeVModel?.categoryObj?.data?.count ?? 0) > 0 ? 135 : 0
        }
        if indexPath.section == 2{
            if let obj = homeVModel?.featuredObj?[indexPath.item]{
                if (obj.style == "style_1") || (obj.style == "style_2") || (obj.style == "style_4"){
                    return  315
                }
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            //Banner
            return (homeVModel?.sliderArray?.count ?? 0) > 0 ? 1 : 0
            
        case 1:
            //Category
            return (homeVModel?.categoryObj?.data?.count ?? 0) > 0 ? 1 : 0
            
        case 2:
            //Featured
            return  (homeVModel?.featuredObj?.count ?? 0) > 0 ? (homeVModel?.featuredObj?.count ?? 0) : 0
            
        default:
            //Items
            return (homeVModel?.itemObj?.data?.count ?? 0) > 0 ? 1 : 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTblCell") as! BannerTblCell
            cell.listArray = homeVModel?.sliderArray
            cell.collctnView.updateConstraints()
            cell.collctnView.reloadData()
            cell.updateConstraints()
            cell.navigationController = self.navigationController
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
            cell.cnstrntHeightSeeAllView.constant = 0
            cell.btnSeeAll.setTitle("", for: .normal)
            cell.cellTypes = .categories
            cell.listArray = homeVModel?.categoryObj?.data
            cell.layoutIfNeeded()
            cell.collctnView.layoutIfNeeded()
            cell.collctnView.updateConstraints()
            cell.collctnView.reloadData()
            cell.updateConstraints()
            cell.navigationController = self.navigationController
            return cell
            
        }else if indexPath.section == 2{
            let obj = homeVModel?.featuredObj?[indexPath.item]
            
            if (obj?.style == "style_1"){
                //Horizontal && increase width
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.istoIncreaseWidth = true
                cell.cnstrntHeightSeeAllView.constant = 35
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cellTypes = .product
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.layoutIfNeeded()
                cell.updateConstraints()
                cell.collctnView.updateConstraints()
                cell.collctnView.reloadData()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }else if (obj?.style == "style_2"){
                //Horizontal
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.collctnView.collectionViewLayout.invalidateLayout()
                cell.istoIncreaseWidth = false
                cell.cnstrntHeightSeeAllView.constant = 35
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cellTypes = .product
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.layoutIfNeeded()
                cell.collctnView.layoutIfNeeded()
                cell.updateConstraints()
                cell.collctnView.updateConstraints()
                cell.collctnView.reloadData()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }else if (obj?.style == "style_3"){
                //vertical
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
                cell.istoIncreaseWidth = false
                cell.cnstrntHeightSeeAllView.constant = 35
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cllctnView.isScrollEnabled = false
                cell.cellTypes = .product
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.layoutIfNeeded()
                cell.cllctnView.layoutIfNeeded()
                cell.cllctnView.updateConstraints()
                cell.cllctnView.reloadData()
                cell.updateConstraints()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }else if (obj?.style == "style_4"){
                //Horizontal && increase width
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.cnstrntHeightSeeAllView.constant = 35
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cellTypes = .product
                cell.istoIncreaseWidth = true
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.layoutIfNeeded()
                cell.collctnView.layoutIfNeeded()
                cell.updateConstraints()
                cell.collctnView.updateConstraints()
                cell.collctnView.reloadData()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }
            
            return UITableViewCell()
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.cnstrntHeightSeeAllView.constant = 0
            cell.btnSeeAll.setTitle("", for: .normal)
            cell.cllctnView.isScrollEnabled = false
            cell.cellTypes = .product
            cell.listArray = homeVModel?.itemObj?.data
            cell.cllctnView.layoutIfNeeded()
            cell.cllctnView.updateConstraints()
            cell.cllctnView.reloadData()
            cell.updateConstraints()
            cell.navigationController = self.navigationController
            return cell
        }
    }
    
    
    
    @objc func selectedSeeAll(_ sender : UIButton){
        
        let tag =  sender.tag  - 2
        
        let sectionObj =  homeVModel?.featuredObj?[tag]
        if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "SeeAllItemVC") as? SeeAllItemVC {
            destVC.obj = sectionObj
            destVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
            // print("up")
            if scrollView == tblView{
                return
            }
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 400)
        {
            if scrollView == tblView{
                if homeVModel?.isDataLoading == false{
                    homeVModel?.getProductListApi()
                }
            }
        }
    }
}


extension HomeVC: RefreshScreen{
    
    
    func refreshFeaturedsList(){
        
        
       UIView.performWithoutAnimation {
            
           if (homeVModel?.featuredObj?.count ?? 0) == 0{
               self.tblView.reloadData()
           }else{
               tblView.reloadSections(IndexSet(integer: 2), with: .none)
           }
       }
    }
    func refreshBannerList(){
        UIView.performWithoutAnimation {
            
            tblView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }
    func refreshCategoriesList(){
       UIView.performWithoutAnimation {
            
            tblView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
    }
    
    
    
    func refreshScreen(){
       UIView.performWithoutAnimation {
            
            self.tblView.reloadData()
        }
    }
   
    
    func newItemRecieve(newItemArray:[Any]?){
        
        if (newItemArray?.count ?? 0) == 0{
            
        }else{
            
            for index1  in 0...((newItemArray as? [ItemModel])?.count ?? 0) - 1 {
                
                if let obj = newItemArray?[index1] as? ItemModel{
                    
                    self.tblView.performBatchUpdates {
                        
                        self.homeVModel?.itemObj?.data?.append(obj)
                        
                        if let cell = self.tblView.cellForRow(at: IndexPath(row: 0, section: 3)) as? HomeTblCell {
                            
                            let indexPath = IndexPath(row: (self.homeVModel?.itemObj?.data?.count ?? 0) - 1, section: 0)
                            cell.listArray =  self.homeVModel?.itemObj?.data
                            cell.cllctnView?.insertItems(at: [indexPath])
                        }
                    }
                    
                }
            }
        }
    }
}
