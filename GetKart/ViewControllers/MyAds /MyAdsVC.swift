//
//  MyAdsVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit
import Kingfisher
import SwiftUI


class MyAdsVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnScrollView:UIScrollView!
    private  var selectedIndex = 500
    private var apiStatus = ""
    private var page = 1
    private  let filters = ["All ads", "Live", "Deactivate", "Under Review","Sold out","Rejected"]
    
    var listArray = [ItemModel]()
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "AdsTblCell", bundle: nil), forCellReuseIdentifier: "AdsTblCell")
        addButtonsToScrollView()
    }
    
    
    func addButtonsToScrollView(){
            
        for index in 0..<filters.count{
            
            let btn = UIButton(frame: CGRect(x: ((120 + 15) * index)  , y: 10, width: 120, height: 40))
            btn.setTitle(filters[index], for: .normal)
            btn.layer.cornerRadius = 10.0
            btn.layer.borderColor = UIColor.black.cgColor
            btn.layer.borderWidth = 1.0
            btn.setTitleColor( UIColor.black, for: .normal)
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
    
    
    func updateCoorOfSelectedTab(){
        
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.backgroundColor = .systemOrange
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.layer.borderColor = UIColor.clear.cgColor
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.clipsToBounds = true
        (self.view.viewWithTag(selectedIndex) as? UIButton)?.setTitleColor(.white, for: .normal)
    }
    
    @objc func filterBtnAction(_ btn : UIButton){
        
        selectedIndex = btn.tag
        
        for index in 0..<filters.count{
            
            (self.view.viewWithTag(500 + index) as? UIButton)?.backgroundColor = .clear
            (self.view.viewWithTag(500 + index) as? UIButton)?.layer.borderColor = UIColor.black.cgColor
            (self.view.viewWithTag(500 + index) as? UIButton)?.layer.borderWidth = 1.0
            (self.view.viewWithTag(500 + index) as? UIButton)?.setTitleColor( UIColor.black, for: .normal)
            (self.view.viewWithTag(500 + index) as? UIButton)?.clipsToBounds = true

        }
        
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.backgroundColor = .systemOrange
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.layer.borderColor = UIColor.clear.cgColor
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.clipsToBounds = true
//        (self.view.viewWithTag(btn.tag) as? UIButton)?.setTitleColor(.white, for: .normal)


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

    
    //Api methods
    func getAdsListApi(){
        
        
        let strUrl = Constant.shared.my_items + "?status=\(apiStatus)?page=\(page)"
        
        
    
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:ItemParse) in
            
            if self.page == 1{
                self.listArray.removeAll()
                self.tblView.reloadData()

            }
            if obj.data != nil {
                self.listArray.append(contentsOf: obj.data?.data ?? [])
                self.tblView.reloadData()
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
        cell.lblPrice.text =  "\(obj.price ?? 0)"
        cell.lblLikeCount.text = "\(obj.totalLikes ?? 0)"
        cell.lblViewCount.text = "\(obj.clicks ?? 0)"
        cell.btnAdStatus.setTitle((obj.status ?? ""), for: .normal)
        cell.imgVwAds.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemObj:(listArray[indexPath.item])))
        AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
    }
    
}

