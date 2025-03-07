//
//  HomeVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI

class HomeVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblAddress:UILabel!
    var homeVModel:HomeViewModel?
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 200
        registerCells()
        homeVModel = HomeViewModel()
        homeVModel?.delegate = self
        homeVModel?.getProductListApi()
    }
    
    
    func registerCells(){
        tblView.register(UINib(nibName: "HomeTblCell", bundle: nil), forCellReuseIdentifier: "HomeTblCell")
        tblView.register(UINib(nibName: "HomeHorizontalCell", bundle: nil), forCellReuseIdentifier: "HomeHorizontalCell")
        tblView.register(UINib(nibName: "BannerTblCell", bundle: nil), forCellReuseIdentifier: "BannerTblCell")        
    }
    
    
    //MARK: UIButton Action
    
    @IBAction func locationBtnAction(_ sender : UIButton){
        
        let vc = UIHostingController(rootView: CountryLocationView(navigationController: self.navigationController))
        self.navigationController?.pushViewController(vc, animated: true)
    
}
    
    @IBAction func searchBtnAction(_ sender : UIButton){
        let hostingController = UIHostingController(rootView: SearchProductView(navigation:AppDelegate.sharedInstance.navigationController)) // Wrap in UIHostingController
        AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
    }

}


extension HomeVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        
        
        if section == 0{
            //Banner
            return (homeVModel?.sliderArray?.count ?? 0) > 0 ? 1 : 0

        }else if section == 1{
            //Category
            return (homeVModel?.categoryObj?.data?.count ?? 0) > 0 ? 1 : 0
      
        }else if section == 2{
           //Featured
            return  (homeVModel?.featuredObj?.count ?? 0) > 0 ? (homeVModel?.featuredObj?.count ?? 0) : 0
            
        }else{
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
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
            cell.cnstrntHeightSeeAllView.constant = 0
            cell.cellTypes = .categories
            cell.listArray = homeVModel?.categoryObj?.data
            cell.layoutIfNeeded()
            cell.collctnView.layoutIfNeeded()
            cell.collctnView.updateConstraints()
            cell.collctnView.reloadData()
            cell.updateConstraints()

            return cell
            
        }else if indexPath.section == 2{
            let obj = homeVModel?.featuredObj?[indexPath.item]
            
            if (obj?.style == "style_1"){
                //Horizontal && increase width
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.istoIncreaseWidth = true

                cell.cnstrntHeightSeeAllView.constant = 35
                cell.cellTypes = .product
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.layoutIfNeeded()
                cell.updateConstraints()
                cell.collctnView.updateConstraints()
                cell.collctnView.reloadData()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                return cell
                
            }else if (obj?.style == "style_2"){
                //Horizontal

                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.collctnView.collectionViewLayout.invalidateLayout()
                cell.istoIncreaseWidth = false
                cell.cnstrntHeightSeeAllView.constant = 35
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
                return cell
                
            }else if (obj?.style == "style_3"){
                //vertical
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
                cell.istoIncreaseWidth = false
                cell.cnstrntHeightSeeAllView.constant = 35
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
                return cell
                
            }else if (obj?.style == "style_4"){
                //Horizontal && increase width

                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.cnstrntHeightSeeAllView.constant = 35
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

                return cell
                
            }
          
            return UITableViewCell()

        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.cnstrntHeightSeeAllView.constant = 0
            cell.cllctnView.isScrollEnabled = false
            cell.cellTypes = .product
            cell.listArray = homeVModel?.itemObj?.data
            cell.cllctnView.layoutIfNeeded()
            cell.cllctnView.updateConstraints()
            cell.cllctnView.reloadData()
            cell.updateConstraints()

            return cell
        }
    }
  
    

       @objc func selectedSeeAll(_ sender : UIButton){
           
           let tag =  sender.tag  - 2
           
          let sectionObj =  homeVModel?.featuredObj?[tag]
           if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "SeeAllItemVC") as? SeeAllItemVC {
               destVC.obj = sectionObj
               AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
           }
       }

    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
            print("up")
            if scrollView == tblView{
                return
            }
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 70)
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
    func refreshScreen(){
        self.tblView.invalidateIntrinsicContentSize()
        self.tblView.reloadData()
    }
}
