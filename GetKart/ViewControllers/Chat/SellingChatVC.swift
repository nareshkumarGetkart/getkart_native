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
        
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE = true
       // getChatList()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE == true{
            self.page = 1
            getChatList()

        }
        
    }

    func getChatList(){
        
        //"type": "seller"  // or buyer
        let params = ["page":1,"type":"seller"] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.sellerChatList.rawValue, params)
    }

    
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading {
            isDataLoading = true
            page = 1
            self.getChatList()
        }
        refreshControl.endRefreshing()
    }
    
    
    //MARK: Observers
    
    
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
                           // listArray[index] = data
                            
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
       
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE = false

        guard let data = notification.userInfo else{
            return
        }
        
        if page == 1{
            self.listArray.removeAll()
        }
        if let response : BuyerChatParse = try? SocketParser.convert(data: data) {
            
            self.listArray.append(contentsOf:response.data?.data ?? [])
            self.tblView.reloadData()
            self.emptyView?.isHidden = (self.listArray.count) > 0 ? true : false
            self.emptyView?.lblMsg?.text = "No chat Found"
            self.emptyView?.subHeadline?.text = ""
            self.page = self.page + 1
        }
        self.isDataLoading = false
        
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
        cell.imgViewProfile.kf.setImage(with:  URL(string: obj.buyer?.profile ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        cell.imgViewItem.kf.setImage(with:  URL(string: obj.item?.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        cell.imgViewItem.layer.cornerRadius = cell.imgViewItem.frame.size.height/2.0
        cell.imgViewItem.clipsToBounds = true
        
        
        cell.lblLastMessage.text = obj.lastMessage?.message ?? ""

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
        destVC.hidesBottomBarWhenPushed = true
        self.navController?.pushViewController(destVC, animated: true)
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


