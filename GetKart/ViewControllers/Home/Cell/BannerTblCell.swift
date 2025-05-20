//
//  BannerTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 03/03/25.
//

import UIKit
import SwiftUI

class BannerTblCell: UITableViewCell {
    
    @IBOutlet weak var collctnView:UICollectionView!
    var listArray:[SliderModel]?
    var timer:Timer? = nil
    var navigationController:UINavigationController?
    private  var x = 0
    @IBOutlet weak var pageControl:UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collctnView.register(UINib(nibName: "BannerCell", bundle: nil), forCellWithReuseIdentifier: "BannerCell")
        self.collctnView.delegate = self
        self.collctnView.dataSource = self
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = Themes.sharedInstance.themeColor
        startTimer()

        
    }
    
    
    deinit{
        timer = nil
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func startTimer() {

        timer =  Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }


    @objc func scrollAutomatically(_ timer1: Timer) {
        
        if let banner = listArray, banner.count > 0{
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


extension BannerTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        pageControl.numberOfPages = listArray?.count ?? 0

        return listArray?.count ?? 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collctnView.frame.size.width, height: 200)
        
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
        if let obj = listArray?[indexPath.item]{
            cell.imgVwBanner.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToScreen(index: indexPath.item, sliderObj: listArray?[indexPath.item])
    }
    

}


extension BannerTblCell{

func navigateToScreen(index:Int, sliderObj:SliderModel?){
    
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
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Cannot open URL")
        }
    }else if sliderObj?.modelType?.contains("Category") == true {

        
        if (sliderObj?.model?.subcategoriesCount ?? 0) > 0{
            
            getCategoriesListApi(sliderObj: sliderObj)
            
        }else{
            let vc = UIHostingController(rootView: SearchWithSortView(categroryId: sliderObj?.modelID ?? 0, navigationController:self.navigationController, categoryName:  sliderObj?.model?.name ?? ""))
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
    
    let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
    if objLoggedInUser.id != nil {
        
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


    
}



