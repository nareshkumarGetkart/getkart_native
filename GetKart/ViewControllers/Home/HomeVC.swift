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
        tblView.estimatedRowHeight = 200
        tblView.rowHeight = UITableView.automaticDimension
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
        
   
    }
    
    @IBAction func searchBtnAction(_ sender : UIButton){
        let hostingController = UIHostingController(rootView: SearchProductView(navigation:AppDelegate.sharedInstance.navigationController)) // Wrap in UIHostingController
        AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
    }

}


extension HomeVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
           
            return (homeVModel?.sliderArray?.count ?? 0) > 0 ? 200 : 0

        } else if indexPath.section == 1{
           // return  310
        }
        return UITableView.automaticDimension
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0{
            return (homeVModel?.sliderArray?.count ?? 0) > 0 ? 1 : 0

        }else if section == 1{
            return (homeVModel?.categoryObj?.data?.count ?? 0) > 0 ? 1 : 0
        }else {
            return (homeVModel?.itemObj?.data?.count ?? 0) > 0 ? 1 : 0
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTblCell") as! BannerTblCell
          
            cell.listArray = homeVModel?.sliderArray

           // (cell.cllctnView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: cell.cllctnView.bounds.size.width/3.0 , height: 130)
            cell.collctnView.updateConstraints()
            cell.collctnView.reloadData()
            cell.updateConstraints()


            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
            cell.cnstrntHeightSeeAllView.constant = 0
            cell.cellTypes = .categories
            cell.listArray = homeVModel?.categoryObj?.data

           // (cell.cllctnView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: cell.cllctnView.bounds.size.width/3.0 , height: 130)
            cell.collctnView.updateConstraints()
            cell.collctnView.reloadData()
            cell.updateConstraints()


            return cell
            
        } else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.cnstrntHeightSeeAllView.constant = 35
            cell.cllctnView.isScrollEnabled = false
            cell.cellTypes = .product
            cell.listArray = homeVModel?.itemObj?.data

            cell.cllctnView.updateConstraints()
            cell.cllctnView.reloadData()
            cell.updateConstraints()

            return cell
        }
        
    }
    
}




extension HomeVC: RefreshScreen{
    func refreshScreen(){
        self.tblView.reloadData()
    }
}
