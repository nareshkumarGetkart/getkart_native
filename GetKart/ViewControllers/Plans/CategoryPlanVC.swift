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
    var itemId:Int?

    
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
         
         
         // Add long press gesture
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0.2   // Adjust sensitivity
            collctnView.addGestureRecognizer(longPress)
     }
    

    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer = nil

    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // User pressed & holding — stop auto-scroll
            timer?.invalidate()
            timer = nil

        case .ended, .cancelled, .failed:
            // User released finger — start auto-scroll again
            startTimer()

        default:
            break
        }
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
                destvc.itemId = itemId
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
        
        timer =  Timer.scheduledTimer(timeInterval: TimeInterval(Local.shared.bannerScrollInterval), target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
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
    // MARK: - Scroll Handling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
        timer = nil
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth/2) / pageWidth)
        pageControl.currentPage = currentPage
        self.x = currentPage + 1
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startTimer()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth/2) / pageWidth)
        pageControl.currentPage = currentPage
        self.x = currentPage + 1
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
    }
       
}



