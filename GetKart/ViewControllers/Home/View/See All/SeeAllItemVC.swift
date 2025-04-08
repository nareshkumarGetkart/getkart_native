//
//  SeeAllItemVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 04/03/25.
//

import UIKit

class SeeAllItemVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collctionView:UICollectionView!
    @IBOutlet weak var btnBack:UIButton!

    var obj:Any?
    
    private var objViewModel:SeeAllViewModel?
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        
        btnBack.setImageColor(color: .black)
       
        collctionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")

        if let recieveObj = obj as? FeaturedClass{
            lblTitle.text = recieveObj.title
            objViewModel = SeeAllViewModel(itemId: recieveObj.id ?? 0)
            objViewModel?.delegate = self
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
            cell.imgViewitem.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        }
        
        return cell
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
            print("up")
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
    
}


extension SeeAllItemVC: RefreshScreen{
    func refreshScreen(){
        self.collctionView.reloadData()
    }
}
