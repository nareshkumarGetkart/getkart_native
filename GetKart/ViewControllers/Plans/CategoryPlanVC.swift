//
//  CategoryPlanVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit
import SwiftUI
class CategoryPlanVC: UIViewController, LocationSelectedDelegate{
   
    @IBOutlet weak var collctnView:UICollectionView!
    private var timer:Timer? = nil
    private  var x = 0
    @IBOutlet weak var pageControl:UIPageControl!
    @IBOutlet weak var adsBgview:UIView!
    private var sliderArray:[SliderModel]?

    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnShowPackage:UIButton!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var bgViewDesc:UIView!

    
     let titleArray =  ["Category","Location"]
     var subTitleArrray = ["Select Category","Select Location"]
     let iconArray =  ["category","location_icon_orange"]
    
    var latitude:String = ""
    var longitude:String = ""
    var city:String = ""
    var state:String = ""
    var country:String = ""
    var locality:String = ""

    var categoryName = ""
    var category_id = 0
    
    
     //MARK: Controller life cycle methods
     override func viewDidLoad() {
         super.viewDidLoad()
         btnBack.setImageColor(color: .label)
         cnstrntHtNavBar.constant = self.getNavBarHt
         // Do any additional setup after loading the view.
         tblView.register(UINib(nibName: "ProfileListTblCell", bundle: nil), forCellReuseIdentifier: "ProfileListTblCell")
         btnShowPackage.layer.cornerRadius = 7.0
         btnShowPackage.clipsToBounds = true
                  
         let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
         let theme = AppTheme(rawValue: savedTheme) ?? .system
         lblDesc.textColor = .label

         if theme == .dark{
             bgViewDesc.backgroundColor = UIColor(hexString: "#342b1e")
         }else{
             bgViewDesc.backgroundColor = UIColor(hexString: "#FEF6E9")
         }
         
         NotificationCenter.default.addObserver(self,selector: #selector(handleLocationSelected(_:)),
                                                name:NSNotification.Name(rawValue:NotiKeysLocSelected.buyPackageNewLocation.rawValue), object: nil)
         
         let city = Local.shared.getUserCity()
         let state = Local.shared.getUserState()
         let country = Local.shared.getUserCountry()
         let latitude = Local.shared.getUserLatitude()
         let longitude = Local.shared.getUserLongitude()
         
         if city.count > 0 && state.count > 0{
             self.latitude = latitude
             self.longitude = longitude
             self.city = city
             self.state = state
             self.country = country
             self.locality = Local.shared.getUserLocality()
             
             subTitleArrray[1] = city + ", " + state + ", " + country
             self.tblView.reloadData()
         }
         
         self.adsBgview.isHidden = true
         self.getSliderListApi()
     }
    

    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer = nil

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
            
            
            self.latitude = latitude
            self.longitude = longitude
            self.city = city
            self.state = state
            self.country = country
            self.locality = locality
            
            subTitleArrray[1] = city + ", " + state + ", " + country
            
            self.tblView.reloadData()
            if self.country.count > 0 && self.category_id > 0 {
                btnShowPackage.isEnabled = true
                btnShowPackage.backgroundColor = .orange
                btnShowPackage.setTitleColor(.white, for: .normal)
            }
            
            
        }
    }
        
    //MARK: UIButton Action Methods
    
    @IBAction func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func fetchCountryListing(){
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            let arrCountry = obj.data?.data ?? []
           var rootView = CountryLocationView(arrCountries: arrCountry, popType: .buyPackage, navigationController: self.navigationController)
           rootView.delLocationSelected = self
           let vc = UIHostingController(rootView:rootView )
           self.navigationController?.pushViewController(vc, animated: true)
       }
   }
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String) {

        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
        
        
        subTitleArrray[1] = city + ", " + state + ", " + country
        
        self.tblView.reloadData()
        if self.country.count > 0 && self.category_id > 0 {
            btnShowPackage.isEnabled = true
            btnShowPackage.backgroundColor = .orange
            btnShowPackage.setTitleColor(.white, for: .normal)
        }
        
    }
    
    func saveCategoryInfo(category_id:Int, categoryName:String ) {
        self.category_id = category_id
        self.categoryName = categoryName
        subTitleArrray[0] = categoryName
        self.tblView.reloadData()
        
        if self.country.count > 0 && self.category_id > 0 {
            btnShowPackage.isEnabled = true
            btnShowPackage.backgroundColor = .orange
            btnShowPackage.setTitleColor(.white, for: .normal)
        }
    }
    
    
    @IBAction func showPackageButtonAction(_ sender : UIButton){
        
        if self.country.count > 0 && self.category_id > 0 {
            
            if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
                destvc.hidesBottomBarWhenPushed = true
                destvc.categoryId = category_id
                destvc.categoryName = categoryName
                destvc.city = city
                destvc.country = country
                destvc.state = state
                destvc.latitude = latitude
                destvc.longitude = longitude
                self.navigationController?.pushViewController(destvc, animated: true)
            }
        }else{
            
            if self.country.count == 0 && self.category_id == 0 {
                AlertView.sharedManager.showToast(message: "Please select category and location")
            }else  if  self.category_id == 0 {
                AlertView.sharedManager.showToast(message: "Please select category")
                
            }else if  self.country.count == 0 {
                AlertView.sharedManager.showToast(message: "Please select location")
            }
        }
    }
     
}

extension CategoryPlanVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListTblCell") as! ProfileListTblCell
        
        cell.lblTitle.text = titleArray[indexPath.row]
        cell.lblSubTitle.text = subTitleArrray[indexPath.row]
        if subTitleArrray[indexPath.row] == "" {
            cell.lblSubTitle.isHidden = true
        }else {
            cell.lblSubTitle.isHidden = false
        }
        cell.imgVwIcon.image = UIImage(named: iconArray[indexPath.row])
        cell.imgVwArrow.isHidden = false
        cell.btnSwitch.isHidden = true
        
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if titleArray[indexPath.row] == "Category" {            
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                destVC.popType = .buyPackage
                destVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        }else if titleArray[indexPath.row] == "Location" {
            self.fetchCountryListing()
        }
    }
    
    
}
      




extension CategoryPlanVC {
    
    func getSliderListApi(){
        let params = ["referrer_url":"PAYMENT_MODE","country":Local.shared.getUserCountry(),"state":Local.shared.getUserState(),"city":Local.shared.getUserCity(),"area":Local.shared.getUserLocality(),"latitude":Local.shared.getUserLatitude(),"longitude":Local.shared.getUserLongitude()]
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.get_slider, param: params,httpMethod: .post, completion:  {[weak self] (obj:SliderModelParse) in
            
            if obj.code == 200 {
                self?.sliderArray = obj.data
                self?.adsSliderInitialize()
            }
        })
    }

    
    
    

 
    
    private func adsSliderInitialize() {
    
        collctnView.register(UINib(nibName: "BannerCell", bundle: nil), forCellWithReuseIdentifier: "BannerCell")
        self.collctnView.delegate = self
        self.collctnView.dataSource = self
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = Themes.sharedInstance.themeColor

        self.adsBgview.isHidden = false
        self.pageControl.numberOfPages = sliderArray?.count ?? 0
        self.pageControl.currentPage = 0
        self.x = 0
        self.collctnView.reloadData()
        startTimer()
        
    }
    
    func startTimer() {
        
        timer =  Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }
    
    
    @objc func scrollAutomatically(_ timer1: Timer) {
        
        if let banner = sliderArray, banner.count > 0{
            if self.x < banner.count {
                let indexPath = IndexPath(item: x, section: 0)
                self.collctnView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.x = self.x + 1
            }else{
                self.x = 0
                self.collctnView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
 

}


extension CategoryPlanVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        pageControl.numberOfPages = sliderArray?.count ?? 0
        
        return sliderArray?.count ?? 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collctnView.frame.size.width, height: 150)
        
    }
    
    // Update pageControl when scrolling ends
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
    
    // (Optional) Update pageControl when programmatic scroll happens (e.g., auto-scroll)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCell
        if let obj = sliderArray?[indexPath.item]{
            cell.imgVwBanner.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
            cell.imgVwBanner.contentMode = .scaleToFill
            cell.imgVwBanner.clipsToBounds = true
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        BannerNavigation.navigateToScreen(index: indexPath.item, sliderObj: sliderArray?[indexPath.item], navigationController: self.navigationController, viewType: "PAYMENT_MODE")
       // navigateToScreen(index: indexPath.item, sliderObj: sliderArray?[indexPath.item])
    }
    
    
    /*
    func navigateToScreen(index:Int, sliderObj:SliderModel?){
        
        if ((sliderObj?.is_active ?? 0) != 0) && (sliderObj?.campaign_id ?? 0) > 0{
            self.campaignClickEventApi(campaign_banner_id: sliderObj?.campaign_id ?? 0)
        }
        if sliderObj?.appRedirection == true && sliderObj?.redirectionType == "AdsListing"{
            
            if isUserLoggedInRequest() {
                if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPlanVC") as? CategoryPlanVC{
                    destvc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(destvc, animated: true)
                }
            }
            
        }else if sliderObj?.appRedirection == true && sliderObj?.redirectionType == "BoostAdsListing"{
            
            if isUserLoggedInRequest() {
                if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPlanVC") as? CategoryPlanVC{
                    destvc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(destvc, animated: true)
                }
            }
        }else if (sliderObj?.thirdPartyLink?.count ?? 0) > 0{
            
            guard let url = URL(string: sliderObj?.thirdPartyLink ?? "") else {
                print("Invalid URL")
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
              //  if sliderObj?.
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL")
            }
        }else if sliderObj?.modelType?.contains("Category") == true {
            
            
            if (sliderObj?.model?.subcategoriesCount ?? 0) > 0{
                
                getCategoriesListApi(sliderObj: sliderObj)
                
            }else{
                let vc = UIHostingController(rootView: SearchWithSortView(categroryId: sliderObj?.modelID ?? 0, navigationController:self.navigationController, categoryName:  sliderObj?.model?.name ?? "", categoryIds: "\(sliderObj?.modelID ?? 0)", categoryImg: sliderObj?.model?.image ?? ""))
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            
            var detailView =  ItemDetailView(navController:  self.navigationController, itemId:sliderObj?.model?.id ?? 0, itemObj: nil, slug: sliderObj?.model?.slug ?? "")
            detailView.returnValue = { [weak self] value in
                if let obj = value{
                    
                }
            }
            let hostingController = UIHostingController(rootView:detailView)
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
        }
    }
    
    
    
    func getCategoriesListApi(sliderObj:SliderModel?){
        
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_categories) { (obj:CategoryParse) in
            
            var subCatArray = [Subcategory]()
            
            if obj.data != nil {
                
                for obj in obj.data?.data ?? []{
                    
                    if obj.id == sliderObj?.modelID {
                        subCatArray = obj.subcategories ?? []
                        break
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    let catIds = ["\(sliderObj?.model?.parentCategoryID ?? 0)","\(sliderObj?.modelID ?? 0)"].joined(separator: ",")
                    
                    let swiftUIView = SubCategoriesView(subcategories: subCatArray, navigationController:  self.navigationController, strTitle: sliderObj?.model?.name ?? "",category_id:"\(sliderObj?.modelID ?? 0)", category_ids:catIds, popType: .categoriesSeeAll) // Create SwiftUI view
                    let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                })
                
            }
        }
    }
    
    
    func isUserLoggedInRequest() -> Bool {
        
        
        if Local.shared.getUserId() > 0 {
            return true
            
            
        }else{
            let logiView = UIHostingController(rootView: LoginRequiredView(loginCallback: {
                //Login
                AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
                
            }))
            logiView.modalPresentationStyle = .overFullScreen // Full-screen modal
            logiView.modalTransitionStyle = .crossDissolve   // Fade-in effect
            logiView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
            navigationController?.topViewController?.present(logiView, animated: true, completion: nil)
            
            return false
        }
    }
    
    
    //Click event api handle
    /*
     --form 'campaign_banner_id="5"' \
     --form 'event_type="view"' \
     --form 'referrer_url="https://example.com/job-offer"' \
     --form 'country="India"' \
     --form 'state="Maharashtra"' \
     --form 'city="Mumbai"' \
     --form 'area="Andheri East"' \
     --form 'pincode="400059"' \
     --form 'latitude="19.1136"' \
     --form 'longitude="72.8697"'METHOD : POST
     */
    
    func campaignClickEventApi(campaign_banner_id:Int){
        
        let params = ["campaign_banner_id":campaign_banner_id,"country":country,"city":city,"state":state,"area":locality,"event_type":"PAYMENT_MODE","latitude":latitude,"longitude":longitude,"referrer_url":""] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.campaign_event, param: params,methodType:.post,showLoader: false) { responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
               // let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    
               
                }else{
                    

                }
            }
        }
    }*/
}



