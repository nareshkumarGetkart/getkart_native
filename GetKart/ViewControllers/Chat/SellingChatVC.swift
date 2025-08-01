//
//  SellingChatVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit



class SellingChatVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    var listArray = [ChatList]()
    var page = 1
    var isDataLoading = false
    private var emptyView:EmptyList?
    
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemYellow
        return refreshControl
    }()
    var navController: UINavigationController? 
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.register(UINib(nibName: "ChatListTblCell", bundle: nil), forCellReuseIdentifier: "ChatListTblCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.chatList), name: NSNotification.Name(rawValue: SocketEvents.sellerChatList.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateChatList), name: NSNotification.Name(rawValue: SocketEvents.updateChatList.rawValue), object: nil)

        tblView.refreshControl = topRefreshControl
        DispatchQueue.main.async{
            self.emptyView = EmptyList(frame: CGRect(x: 0, y: 0, width:  self.tblView.frame.size.width, height:  self.tblView.frame.size.height))
            self.tblView.addSubview(self.emptyView!)
            self.emptyView?.isHidden = true
            self.emptyView?.lblMsg?.text = "No chat Found"
            self.emptyView?.imageView?.image = UIImage(named: "no_chat_found")
        }
        
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
        
        NotificationCenter.default.addObserver(self,selector: #selector(noInternet(notification:)),
                                               name:NSNotification.Name(rawValue:NotificationKeys.noInternet.rawValue), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER == true{
            self.page = 1
            getChatList()
        }
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
    }
    

    func getChatList(){
        isDataLoading = true
        //"type": "seller"  // or buyer
        let params = ["page":page,"type":"seller"] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.sellerChatList.rawValue, params)
    }

    
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
       
        if !AppDelegate.sharedInstance.isInternetConnected{
            isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
      
        }else if !isDataLoading {
            isDataLoading = true
            page = 1
            self.getChatList()
        }
        refreshControl.endRefreshing()
    }
    
    
    //MARK: Observers
    
    @objc func noInternet(notification:Notification?){
      
        self.isDataLoading = false
        AlertView.sharedManager.showToast(message: "No internet connection")

    }
    @objc func updateChatList(notification: Notification) {
        
        
        guard let data = notification.userInfo else{
            return
        }
        
        if let response : ParseUpdatedChat = try? SocketParser.convert(data: data) {
            
            if response.type?.lowercased() == "seller"{
                
                var isFound = false
                for (index,chat) in listArray.enumerated(){
                    
                    if chat.id == response.data?.id{
                        isFound = true
                        if let data = response.data{
                            listArray.remove(at: index)
                            listArray.insert(data, at: 0)
                        }
                        break
                    }
                }
                
                if !isFound{
                    if let data = response.data{
                        
                        listArray.insert(data, at: 0)
                    }
                }
                
                self.tblView.reloadData()
                
            }
        }
    }
    
    
    @objc func chatList(notification: Notification) {
       
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = false

        guard let data = notification.userInfo else{
            return
        }
      
        if let response : BuyerChatParse = try? SocketParser.convert(data: data) {
    
            if response.code == 200{
                
                if page == 1{
                    self.listArray.removeAll()
                }
                
                
                
                if  self.listArray.count > 0 && (response.data?.data ?? []).count == 0 {
                    self.isDataLoading = false
                    return
                }else{
                    self.listArray.append(contentsOf:response.data?.data ?? [])
                    self.tblView.reloadData()
                }
                
//                self.listArray.append(contentsOf:response.data?.data ?? [])
//                self.tblView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.isDataLoading = false
                    self.page = self.page + 1
                })
            }else{
                self.isDataLoading = false

            }
            
            self.emptyView?.isHidden = (self.listArray.count) > 0 ? true : false
            self.emptyView?.lblMsg?.text = "No chat Found"
            self.emptyView?.subHeadline?.text = ""
 
        }
        
    }
}


extension SellingChatVC: PageVisible {
    func pageDidBecomeVisible() {
        // do something when this page becomes visible
        
        print("Page is visible == SellingChatVC")
        
        if Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER == true{
            self.page = 1
            getChatList()

        }
        
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
    }
}


extension SellingChatVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return listArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTblCell") as! ChatListTblCell
        let obj = listArray[indexPath.item]
        cell.lblName.text = obj.buyer?.name ?? ""
        cell.lblDesc.text = obj.item?.name ?? ""
        cell.imgViewProfile.kf.setImage(with:  URL(string: obj.buyer?.profile ?? "") , placeholder:ImageName.userPlaceHolder)
        cell.imgViewItem.kf.setImage(with:  URL(string: obj.item?.image ?? "") , placeholder: ImageName.getKartplaceHolder)
        cell.imgViewItem.layer.cornerRadius = cell.imgViewItem.frame.size.height/2.0
        cell.imgViewItem.clipsToBounds = true
        
        cell.imgViewItem.backgroundColor = UIColor(hexString: "#FEF6E9")
        cell.lblLastMessage.text = obj.lastMessage?.message ?? ""

        
        if (obj.item?.name ?? "").count == 0{
            cell.lblDesc.isHidden = true
        }else{
            cell.lblDesc.isHidden = false
        }
        
        if (obj.lastMessage?.message?.count ?? 0) > 0 {
            cell.lblLastMessage.isHidden = false
            
            if obj.lastMessage?.audio?.count ?? 0 > 0 {
                cell.lblLastMessage.text = "📢"
            }else if obj.lastMessage?.file?.count ?? 0 > 0{
                cell.lblLastMessage.text = "📝"
            }
        }else{
            cell.lblLastMessage.isHidden = true
        }
        
        if (obj.readAt?.count ?? 0) == 0 && (obj.chatCount ?? 0 > 0){
            cell.lblDot.isHidden = false
        }else{
            cell.lblDot.isHidden = true
        }
        
        cell.btnOption.tag = indexPath.row
        cell.btnOption.addTarget(self, action: #selector(optionBtnAction(_ : )), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        listArray[indexPath.item].readAt = listArray[indexPath.item].updatedAt
        self.tblView.reloadData()
        let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        destVC.item_offer_id = listArray[indexPath.item].id ?? 0
        destVC.userId = listArray[indexPath.item].buyerID ?? 0
        destVC.itemImg = listArray[indexPath.item].item?.image ?? ""
        destVC.itemName = listArray[indexPath.item].item?.name ?? ""
        destVC.name = listArray[indexPath.item].buyer?.name ?? ""
        destVC.profileImg = listArray[indexPath.item].buyer?.profile ?? ""
        destVC.price = listArray[indexPath.item].item?.price ?? 0.0
        destVC.hidesBottomBarWhenPushed = true
        self.navController?.pushViewController(destVC, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
           // print("up")
            if scrollView == tblView{
                return
            }
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            if scrollView == tblView{
                if isDataLoading == false && listArray.count > 0{
                    isDataLoading = true

                    getChatList()
                }
            }
        }
    }
  
    
      @objc func optionBtnAction(_ sender : UIButton){
          
          let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
          
          let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          actionSheetAlertController.addAction(cancelActionButton)
       
          
          let deleteChat = UIAlertAction(title: "Delete Chat", style: .default) { (action) in
              
              
          }
          
          actionSheetAlertController.addAction(deleteChat)
         
          self.present(actionSheetAlertController, animated: true, completion: nil)
      }
    
    
}


