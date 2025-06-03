//
//  SeeAllItemVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 04/03/25.
//

import UIKit
import SwiftUI
import Kingfisher

class SeeAllItemVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collctionView:UICollectionView!
    @IBOutlet weak var btnBack:UIButton!

    var obj:Any?
    private var objViewModel:SeeAllViewModel?
    private var emptyView:EmptyList?

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        
        btnBack.setImageColor(color: .label)
       
        collctionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")

        
        DispatchQueue.main.async{
            self.emptyView = EmptyList(frame: CGRect(x: 0, y: 0, width:  self.collctionView.frame.size.width, height:  self.collctionView.frame.size.height))
            self.collctionView.addSubview(self.emptyView!)
            self.emptyView?.isHidden = true
            self.emptyView?.lblMsg?.text = ""
            self.emptyView?.imageView?.image = UIImage(named: "no_data_found_illustrator")
        }
        
        
        if let recieveObj = obj as? FeaturedClass{
            lblTitle.text = recieveObj.title
            objViewModel = SeeAllViewModel(itemId: recieveObj.id ?? 0)
            objViewModel?.delegate = self
        }
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !AppDelegate.sharedInstance.isInternetConnected{
            objViewModel?.isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
    }
    
    //MARK: UIButton Action Methods
    @IBAction  func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension SeeAllItemVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objViewModel?.listArray?.count ?? 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:  (self.collctionView.bounds.size.width/2.0 - 2.5) , height: 260)
        
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.bgView.addShadow()
        
        if let obj = objViewModel?.listArray?[indexPath.item] as? ItemModel{
            cell.lblItem.text = obj.name
            cell.lblAddress.text = obj.address
            cell.lblPrice.text =  "\(Local.shared.currencySymbol) \(obj.price ?? 0)"
            
            cell.lblBoost.isHidden = ((obj.isFeature ?? false) == true) ? false : true
            
            cell.btnLike.tag = indexPath.item
            cell.btnLike.addTarget(self, action: #selector(likebtnAction), for: .touchUpInside)
            
            let imgName = (obj.isLiked ?? false) ? "like_fill" : "like"
            cell.btnLike.setImage(UIImage(named: imgName), for: .normal)
            cell.btnLike.backgroundColor = .systemBackground
            let processor = DownsamplingImageProcessor(size: cell.imgViewitem.bounds.size)
            
            cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale)
            ])
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var detailView = ItemDetailView(navController:   self.navigationController, itemId:(objViewModel?.listArray?[indexPath.item] as? ItemModel)?.id ?? 0, itemObj: objViewModel?.listArray?[indexPath.item], slug: objViewModel?.listArray?[indexPath.item].slug)
        detailView.returnValue = { [self] value in
           if let obj = value{
               objViewModel?.listArray?[indexPath.item] = obj
               self.collctionView.reloadItems(at: [indexPath])
           }
       }
        let hostingController = UIHostingController(rootView: detailView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
          //  print("up")
            if scrollView == collctionView{
                return
            }
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 70)
        {
            if scrollView == collctionView{
                if objViewModel?.isDataLoading == false{
                    objViewModel?.getItemListApi()
                }
            }
        }
    }
    
    @objc  func likebtnAction(_ sender : UIButton){
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            
            if  var obj = (objViewModel?.listArray?[sender.tag] as? ItemModel){
                obj.isLiked?.toggle()
                objViewModel?.listArray?[sender.tag] = obj
                addToFavourite(itemId:obj.id ?? 0)
                self.collctionView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                
            }
        }
    }
    
    
    func addToFavourite(itemId:Int){
        
        let params = ["item_id":"\(itemId)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                
            }
        }
    }
    
}


extension SeeAllItemVC: RefreshScreen{
    func refreshScreen(){
        self.collctionView.reloadData()
        
   
    }
    
    func newItemRecieve(newItemArray:[Any]?){
        if (newItemArray?.count ?? 0) == 0{
            
            self.emptyView?.isHidden = (self.objViewModel?.listArray?.count ?? 0) > 0 ? true : false
            self.emptyView?.lblMsg?.text = "No Ads Found"
            self.emptyView?.subHeadline?.text = "There are currently no ads available"
            
        }else{
       
            for index1  in 0...((newItemArray as? [ItemModel])?.count ?? 0) - 1 {
            
            if let obj = newItemArray?[index1] as? ItemModel{
                
                self.objViewModel?.listArray?.append(obj)
                let indexPath = IndexPath(row: (self.objViewModel?.listArray?.count ?? 0) - 1, section: 0)
                self.collctionView?.insertItems(at: [indexPath])
            }
        }
    }
        
    }

}
