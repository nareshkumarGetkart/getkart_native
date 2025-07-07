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
        btnLocation.backgroundColor = .systemBackground
        btnLocation.setImageColor(color: .label)
        btnLocation.clipsToBounds = true
        configureTableView()
        updateLocationLabel(city: Local.shared.getUserCity(), state: Local.shared.getUserState(), country: Local.shared.getUserCountry())
        homeVModel = HomeViewModel()
        homeVModel?.delegate = self
        homeVModel?.getProductListApi()
        
        NotificationCenter.default.addObserver(self,selector:
                                                #selector(handleLocationSelected(_:)),
                                               name:NSNotification.Name(rawValue:NotiKeysLocSelected.homeNewLocation.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self,selector:
                                                #selector(noInternet(notification:)),
                                               name:NSNotification.Name(rawValue:NotificationKeys.noInternet.rawValue),
                                               object: nil)
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

    
    /*
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
    */
    
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
    
    
    //MARK: Observer Location
    @objc func handleLocationSelected(_ notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String: Any]
        {
            let city = userInfo["city"] as? String ?? ""
            let state = userInfo["state"] as? String ?? ""
            let country = userInfo["country"] as? String ?? ""
            let latitude = userInfo["latitude"] as? String ?? ""
            let longitude = userInfo["longitude"] as? String ?? ""
            let locality = userInfo["locality"] as? String ?? ""
            
            handleLocationUpdate(city: city, state: state, country: country, latitude: latitude, longitude: longitude)
         /*
            print("Received Location: \(city), \(state), \(country)")
                        
            homeVModel?.page = 1
            //homeVModel?.itemObj?.data = nil
           // homeVModel?.featuredObj = nil
            homeVModel?.itemObj?.data?.removeAll()
            homeVModel?.featuredObj?.removeAll()
            self.tblView.reloadData()
            tblView.setNeedsLayout()
            tblView.layoutIfNeeded()
            
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
            */
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
            homeVModel?.itemObj?.data = nil
            homeVModel?.featuredObj = nil
            homeVModel?.itemObj?.data?.removeAll()
            homeVModel?.featuredObj?.removeAll()
            self.tblView.reloadData()
            homeVModel?.getProductListApi()
            if (homeVModel?.sliderArray?.count ?? 0) == 0{
                homeVModel?.getSliderListApi()
            }
            if (homeVModel?.categoryObj?.data?.count ?? 0) == 0{
                homeVModel?.getCategoriesListApi()
            }
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
//        let hostingController = UIHostingController(rootView: SearchProductView(navigation:self.navigationController)) // Wrap in UIHostingController
//        hostingController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(hostingController, animated: true)
//        
            
        
        let swiftUIview = SearchWithSortView(categroryId: 0, navigationController:self.navigationController, categoryName:  "", categoryIds: "", categoryImg: "",pushToSuggestion:true)
        let vc = UIHostingController(rootView: swiftUIview)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func micBtnAction(_ sender : UIButton){
        
        
    }
    
    @IBAction func filterBtnAction(_ sender : UIButton){
        
        
        let swiftUIview = SearchWithSortView(categroryId: 0, navigationController:self.navigationController, categoryName:  "", categoryIds: "", categoryImg: "",pushToSuggestion:false,pushToFilter:true)
        let vc = UIHostingController(rootView: swiftUIview)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
//        let hostingController = UIHostingController(rootView: SearchProductView(navigation:self.navigationController,navigateToFilterScreen: true))
//        hostingController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(hostingController, animated: false)
        
                
//        let hostingController = UIHostingController(rootView: FilterView(navigation:self.navigationController))
//        hostingController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(hostingController, animated: false)
//
    }
    
    
    @IBAction func logoBtnAction(_ sender : UIButton){
        
        
    }

    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String){

        handleLocationUpdate(city: city, state: state, country: country, latitude: latitude, longitude: longitude)
       /* homeVModel?.page = 1
        homeVModel?.itemObj?.data = nil
        homeVModel?.featuredObj = nil
        homeVModel?.itemObj?.data?.removeAll()
        homeVModel?.featuredObj?.removeAll()
        self.tblView.reloadData()
        tblView.setNeedsLayout()
        tblView.layoutIfNeeded()
        
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
        */
    }
}

/*
extension HomeVC:FilterSelected{
    
    
    func filterSelectectionDone(dict:Dictionary<String,Any>, dataArray:Array<CustomField>, strCategoryTitle:String) {
        print(dict)
        
        homeVModel?.page = 1
        homeVModel?.itemObj?.data = nil
        self.tblView.reloadData()
        homeVModel?.getProductListApi()
        
        if let  city = dict["city"] as? String,let  state = dict["state"] as? String,let  country = dict["country"] as? String{
            
            handleLocationUpdate(city: city, state: state, country: country, latitude: <#T##String#>, longitude: <#T##String#>)
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

*/
extension HomeVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return (homeVModel?.categoryObj?.data?.count ?? 0) > 0 ? 135 : 0
        }
        if indexPath.section == 2{
            
            if (homeVModel?.featuredObj?.count ?? 0) == 0{
                return 0
            }else if let obj = homeVModel?.featuredObj?[indexPath.item]{
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
        case 3:
            //Items
            return (homeVModel?.itemObj?.data?.count ?? 0) > 0 ? 1 : 0
        default:
            return 0
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTblCell") as! BannerTblCell
            if let banners = homeVModel?.sliderArray {
                cell.configure(with: banners)
            }
             cell.navigationController = self.navigationController

//            cell.listArray = homeVModel?.sliderArray
//            cell.collctnView.updateConstraints()
//            cell.collctnView.reloadData()
//            cell.updateConstraints()
            return cell
            
        } else if indexPath.section == 1 {
            guard let cell = tblView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as? HomeHorizontalCell else { return UITableViewCell() }
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
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
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
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
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
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
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
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
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
            
        }else if indexPath.section == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.cnstrntHeightSeeAllView.constant = 0
            cell.btnSeeAll.setTitle("", for: .normal)
            cell.cllctnView.isScrollEnabled = false
            cell.cellTypes = .product
            cell.listArray = homeVModel?.itemObj?.data
            cell.section = indexPath.section
            cell.rowIndex = indexPath.row
            cell.delegateUpdateList = self
            cell.cllctnView.layoutIfNeeded()
            cell.cllctnView.updateConstraints()
            cell.cllctnView.reloadData()
            cell.updateConstraints()
            cell.navigationController = self.navigationController
            return cell
        }
        return UITableViewCell()

    }
    
    
    
    @objc func selectedSeeAll(_ sender : UIButton){
        
        let tag =  sender.tag  - 2
        
        let sectionObj =  homeVModel?.featuredObj?[tag]
        if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "SeeAllItemVC") as? SeeAllItemVC {
            destVC.obj = sectionObj
            destVC.city = homeVModel?.city ?? ""
            destVC.state = homeVModel?.state ?? ""
            destVC.country = homeVModel?.country ?? ""
            destVC.latitude = homeVModel?.latitude ?? ""
            destVC.longitude = homeVModel?.longitude ?? ""
            
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
                if homeVModel?.isDataLoading == false && (homeVModel?.itemObj?.data?.count ?? 0) > 0{
                    homeVModel?.getProductListApi()
                }
            }
        }
    }
}


extension HomeVC: RefreshScreen{
    
    
    func refreshFeaturedsList(){
        
        if (homeVModel?.featuredObj?.count ?? 0) == 0{
            self.tblView.reloadData()
            
        }else{
            tblView.reloadSections(IndexSet(integer: 2), with: .none)
        }
    }
    
    func refreshBannerList(){
        
        tblView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    func refreshCategoriesList(){
        
        tblView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    func refreshScreen(){
        self.tblView.reloadData()
        tblView.setNeedsLayout()
        tblView.layoutIfNeeded()
    }
    
    
    func newItemRecieve(newItemArray:[Any]?){
        guard let newItems = newItemArray as? [ItemModel], !newItems.isEmpty else { return }
        
        let section = 3
        let oldCount = homeVModel?.itemObj?.data?.count ?? 0
        homeVModel?.itemObj?.data?.append(contentsOf: newItems)
        let newCount = homeVModel?.itemObj?.data?.count ?? 0
        
        let newIndexPaths = (oldCount..<newCount).map { IndexPath(item: $0, section: 0) }
        
        DispatchQueue.main.async {
            if let cell = self.tblView.cellForRow(at: IndexPath(row: 0, section: section)) as? HomeTblCell {
                cell.listArray = self.homeVModel?.itemObj?.data
                cell.cllctnView.performBatchUpdates({
                    cell.cllctnView.insertItems(at: newIndexPaths)
                }, completion: nil)
            } else {
                // If cell not visible, reload section to reflect new data when it comes into view
                self.tblView.reloadSections(IndexSet(integer: section), with: .none)
            }
            
            // Recalculate height if needed
            self.tblView.beginUpdates()
            self.tblView.endUpdates()
        }
    }
}


extension HomeVC:UPdateListDelegate{
    
    func updateArray(section:Int,rowIndex:Int,arrIndex:Int,obj:Any?){

        switch section {
            
        case 0: break
            //Banner
            
        case 1: break
            //Category
            
        case 2:
            //Featured
            if let selObj = obj as? ItemModel{
                homeVModel?.featuredObj?[rowIndex].sectionData?[arrIndex] = selObj
            }
        case 3:
            //Items
            if let selObj = obj as? ItemModel{
                homeVModel?.itemObj?.data?[rowIndex] = selObj
            }
        default:
            break
            
        }
        
    }
    
}


// Optimized HomeVC

extension HomeVC {


    func refreshTableOnFilterOrLocationChange() {
        homeVModel?.page = 1
        homeVModel?.itemObj?.data?.removeAll()
        homeVModel?.featuredObj?.removeAll()
        tblView.reloadData()
    }

    func configureTableView() {
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 200
        tblView.refreshControl = topRefreshControl
        self.topRefreshControl.backgroundColor = .clear
        
        registerCells()
    }

    func handleLocationUpdate(city: String, state: String, country: String, latitude: String, longitude: String) {
        homeVModel?.city = city
        homeVModel?.state = state
        homeVModel?.country = country
        homeVModel?.latitude = latitude
        homeVModel?.longitude = longitude
        refreshTableOnFilterOrLocationChange()
        homeVModel?.getProductListApi()
        homeVModel?.getFeaturedListApi()
        updateLocationLabel(city: city, state: state, country: country)
    }

    func updateLocationLabel(city: String, state: String, country: String) {
        var locStr = city
        if !state.isEmpty { locStr += ", \(state)" }
        if !country.isEmpty { locStr += ", \(country)" }
        lblAddress.text = locStr.isEmpty ? "All \(country)" : locStr
        
        if state.count == 0 && city.count == 0{
            if country.count == 0{
                lblAddress.text =  "All India"
            }else{
                lblAddress.text =  "All \(country)"
            }
        }
        if let text = lblAddress.text, text.hasPrefix(",") {
            lblAddress.text = String(text.dropFirst())
        }
    }
}

