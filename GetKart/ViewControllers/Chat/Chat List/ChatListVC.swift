//
//  ChatListVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI


class ChatListVC: UIViewController {
    
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnMenu:UIButton!
    @IBOutlet weak var searchBgView:UIView!
    @IBOutlet weak var btnEdit:UIButton!
    @IBOutlet weak var btnSearch:UIButton!

    private var listArray = [ChatList]()
    private var page = 1
    private var isDataLoading = false
    private var emptyView:EmptyList?
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemYellow
        return refreshControl
    }()
    
    
    private var selectedIndexPaths: [IndexPath] = []
    private var isDeleteMode = false
    
    lazy var cancelButton = UIBarButtonItem(
        title: "Cancel",
        style: .plain,
        target: self,
        action: #selector(cancelDeleteMode)
    )

    lazy var doneButton = UIBarButtonItem(
        title: "Done",
        style: .done,
        target: self,
        action: #selector(doneDeleteMode)
    )
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMenu.setImageColor(color: .label)
        btnEdit.setImageColor(color: .label)
        btnSearch.setImageColor(color: .gray)
        btnSearch.layer.cornerRadius = 8.0
        btnSearch.clipsToBounds = true
        
        cnstrntHtNavBar.constant = self.getNavBarHt
        SocketIOManager.sharedInstance.checkSocketStatus()
        
        tblView.register(UINib(nibName: "ChatListTblCell", bundle: nil), forCellReuseIdentifier: "ChatListTblCell")
        addObservers()
       
        
        tblView.refreshControl = topRefreshControl
        
        DispatchQueue.main.async{
            self.emptyView = EmptyList(frame: CGRect(x: 0, y: 0, width:  self.tblView.frame.size.width, height:  self.tblView.frame.size.height))
            self.tblView.addSubview(self.emptyView!)
            self.emptyView?.isHidden = true
            self.emptyView?.lblMsg?.text = "No chat Found"
            self.emptyView?.imageView?.image = UIImage(named: "no_chat_found")
        }
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
              
        tblView.allowsMultipleSelectionDuringEditing = true

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketIOManager.sharedInstance.checkSocketStatus()

        if Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER == true{
            self.page = 1
            getChatList()
        }
        
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
        
    }
    
    //MARK: Add Observers
  
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.chatList), name: NSNotification.Name(rawValue: SocketEvents.chatList.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.updateChatList), name: NSNotification.Name(rawValue: SocketEvents.updateChatList.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self,selector:
                                                #selector(noInternet(notification:)),
                                               name:NSNotification.Name(rawValue:NotificationKeys.noInternet.rawValue), object: nil)
    }
    
    //MARK: UIbutton Action Methods
    @IBAction func newChatMessage(_ sender:UIButton){
        
        let view = NewMessageView(navigationController: navigationController)
        let hosting = UIHostingController(rootView: view)
        hosting.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(hosting, animated: true)
        
    }
    
    
    @IBAction func searchMessagedUser(_ sender:UIButton){
        
        let view = SearchMessagedUserView(navigationController: navigationController)
        let hosting = UIHostingController(rootView: view)
        hosting.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(hosting, animated: true)
        
    }
    
    
    
    @IBAction func threeDotOptionBtnAction(_ sender : UIButton){
       /* let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)
     
        
        let deleteChat = UIAlertAction(title: "Delete Chat", style: .default) { (action) in
            
            self.deleteChatAction(sender)
        }
        
        actionSheetAlertController.addAction(deleteChat)
        
     
       
        self.present(actionSheetAlertController, animated: true, completion: nil)*/
        
        /*let hostingController = UIHostingController(rootView: BlockedUserView(navigationController: self.navigationController)) // Wrap in UIHostingController
        hostingController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hostingController, animated: true)*/
    }
    
    func updateandcheckStatus(){
        SocketIOManager.sharedInstance.checkSocketStatus()
    }
    
    
    
    func deleteChatAction(_ sender: UIButton) {
        
        tblView.setEditing(true, animated: true)

            tblView.allowsMultipleSelectionDuringEditing = true

            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = doneButton

            selectedIndexPaths.removeAll()

            AlertView.sharedManager.showToast(message: "Select up to 5 chats")
    }
    
    @objc func cancelDeleteMode() {

        selectedIndexPaths.removeAll()

        tblView.setEditing(false, animated: true)

        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil

        tblView.reloadData()
    }
    
    @objc func doneDeleteMode() {

        if selectedIndexPaths.isEmpty {

            AlertView.sharedManager.showToast(message: "Select chats")

            return
        }

        let selectedRows = selectedIndexPaths.map { $0.row }

        let roomIds = selectedRows.compactMap {
            listArray[$0].roomId
        }

        print(roomIds)

        // DELETE API HERE

        listArray.removeAll { item in
            roomIds.contains(item.roomId ?? 0)
        }

        selectedIndexPaths.removeAll()

        tblView.setEditing(false, animated: true)

        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil

        tblView.reloadData()
    }
    
    @IBAction func confirmDeleteAction(_ sender: UIButton) {

        let selectedRows = selectedIndexPaths.map { $0.row }

        let roomIds = selectedRows.compactMap {
            listArray[$0].roomId
        }

        print(roomIds)

        // API CALL HERE

        listArray.removeAll { item in
            roomIds.contains(item.roomId ?? 0)
        }

        selectedIndexPaths.removeAll()

        tblView.setEditing(false, animated: true)

        tblView.reloadData()
    }
}


extension ChatListVC  {
    
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
    
    func getChatList(){
        
        isDataLoading = true
        // "type": "seller"  // or buyer
        let params = ["page":page] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.chatList.rawValue, params)
        
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
            
                
                var isFound = false
                for (index,chat) in listArray.enumerated(){
                    
//                    if chat.roomId == response.data?.id{
                    if chat.roomId == response.data?.roomId{

                        isFound = true
                        if let data = response.data{
                            listArray.remove(at: index)
                            listArray.insert(data, at: 0)
                           // listArray[index] = data
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
    
    @objc func chatList(notification: Notification) {
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = false

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



extension ChatListVC:UITableViewDelegate,UITableViewDataSource{
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return  UITableView.automaticDimension //85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return listArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTblCell") as! ChatListTblCell
        let obj = listArray[indexPath.item]
        cell.lblName.text = obj.user?.name ?? ""
        cell.selectionStyle = .default
        cell.contentView.isUserInteractionEnabled = false
        cell.imgViewProfile.configure(name: obj.user?.name ?? "", imageUrl: obj.user?.profile ?? "",fontSize: 14.0)
        
        cell.setDateTime(isoDateString: obj.lastMessageTime ?? "")
        cell.lblLastMessage.isHidden = true
        
        if (obj.lastMessage?.message?.count ?? 0) > 0 {
            cell.lblLastMessage.isHidden = false
            cell.lblLastMessage.text = obj.lastMessage?.message ?? ""
            
        }else  if obj.lastMessage?.audio?.count ?? 0 > 0 {
            cell.lblLastMessage.text = "📢"
            cell.lblLastMessage.isHidden = false
            
        }else if obj.lastMessage?.file?.count ?? 0 > 0{
            cell.lblLastMessage.text = "📝"
            cell.lblLastMessage.isHidden = false
        }
        
        cell.bgView.backgroundColor = .systemBackground
        
        
                
        if (obj.readAt?.count ?? 0) == 0 && (obj.unreadCount ?? 0 > 0){
            cell.lblDot.isHidden = false
            cell.lblLastMessage.font = UIFont.Inter.bold(size: 15.0).font

        }else{
            cell.lblDot.isHidden = true
            cell.lblLastMessage.font = UIFont.Inter.regular(size: 15.0).font

        }
        
        
       
        return cell
    }
    

    
  /*  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listArray[indexPath.item].readAt = listArray[indexPath.item].updatedAt
        self.tblView.reloadData()
        let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        destVC.item_offer_id = listArray[indexPath.item].roomId ?? 0
        destVC.userId = listArray[indexPath.item].user?.id ?? 0
        destVC.name = listArray[indexPath.item].user?.name ?? ""
        destVC.profileImg = listArray[indexPath.item].user?.profile ?? ""
        destVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    */
    
    func tableView(_ tableView: UITableView,
                   shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        return tableView.isEditing ? .none : .delete
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        if tableView.isEditing {
            selectedIndexPaths.removeAll { $0 == indexPath }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // DELETE MODE
        if tableView.isEditing {

            if selectedIndexPaths.count >= 5 &&
                !selectedIndexPaths.contains(indexPath) {

                tableView.deselectRow(at: indexPath, animated: true)

                AlertView.sharedManager.showToast(message: "Maximum 5 chats allowed")
                return
            }

            selectedIndexPaths.append(indexPath)

            return
        }

        // NORMAL OPEN CHAT
        listArray[indexPath.item].readAt = listArray[indexPath.item].updatedAt

        self.tblView.reloadData()

        let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC

        destVC.item_offer_id = listArray[indexPath.item].roomId ?? 0
        destVC.userId = listArray[indexPath.item].user?.id ?? 0
        destVC.name = listArray[indexPath.item].user?.name ?? ""
        destVC.profileImg = listArray[indexPath.item].user?.profile ?? ""
        destVC.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(destVC, animated: true)
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





//MARK:
extension ChatListVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1
    }
}


protocol PageVisible {
    func pageDidBecomeVisible()
}

