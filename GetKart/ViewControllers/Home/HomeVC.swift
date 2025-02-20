//
//  HomeVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class HomeVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblAddress:UILabel!

    
    //MARK: Controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cnstrntHtNavBar.constant = self.getNavBarHt
        registerCells()
    }
    
    
    func registerCells(){
        
        tblView.register(UINib(nibName: "HomeTblCell", bundle: nil), forCellReuseIdentifier: "HomeTblCell")

    }
    
    
    //MARK: UIButton Action
    
    @IBAction func locationBtnAction(_ sender : UIButton){
        
   
    }
    
    @IBAction func searchBtnAction(_ sender : UIButton){
        
    }

}


extension HomeVC:UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.bgViewSeeAll.isHidden = true
            
            let alignedFlowLayout = cell.cllctnView.collectionViewLayout as? UICollectionViewFlowLayout
            alignedFlowLayout?.minimumInteritemSpacing = 10
            alignedFlowLayout?.minimumLineSpacing = 10
            alignedFlowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            alignedFlowLayout?.scrollDirection = .horizontal
          

            return cell
            
        }else  if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.bgViewSeeAll.isHidden = false
            let alignedFlowLayout = cell.cllctnView.collectionViewLayout as? UICollectionViewFlowLayout
            alignedFlowLayout?.minimumInteritemSpacing = 10
            alignedFlowLayout?.minimumLineSpacing = 10
            alignedFlowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            alignedFlowLayout?.scrollDirection = .horizontal
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.bgViewSeeAll.isHidden = false
            let alignedFlowLayout = cell.cllctnView.collectionViewLayout as? UICollectionViewFlowLayout
            alignedFlowLayout?.minimumInteritemSpacing = 10
            alignedFlowLayout?.minimumLineSpacing = 10
            alignedFlowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            alignedFlowLayout?.scrollDirection = .vertical

            return cell
        }
        
    }
    
}


