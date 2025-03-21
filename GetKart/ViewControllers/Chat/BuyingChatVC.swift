//
//  BuyingChatVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit
import Kingfisher

class BuyingChatVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    
    var listArray = [ChatList]()
    var page = 1
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.register(UINib(nibName: "ChatListTblCell", bundle: nil), forCellReuseIdentifier: "ChatListTblCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.chatList), name: NSNotification.Name(rawValue: SocketEvents.buyerChatList.rawValue), object: nil)
        
        getChatList()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getChatList(){
        
        // "type": "seller"  // or buyer
        let params = ["page":page,"type":"buyer"] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.buyerChatList.rawValue, params)
        
    }
    
    //MARK: Observers
    
    @objc func chatList(notification: Notification) {
        
        guard let data = notification.userInfo else{
            return
        }
        
        if page == 1{
            self.listArray.removeAll()
        }
        if let response : BuyerChatParse = try? SocketParser.convert(data: data) {
            
            self.listArray.append(contentsOf:response.data?.data ?? [])
            self.tblView.reloadData()
        }
    }
}

extension BuyingChatVC:UITableViewDelegate,UITableViewDataSource{
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return listArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTblCell") as! ChatListTblCell
        let obj = listArray[indexPath.item]
        cell.lblName.text = obj.seller?.name ?? ""
        cell.lblDesc.text = obj.item?.name ?? ""
        cell.imgViewProfile.kf.setImage(with:  URL(string: obj.seller?.profile ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        cell.imgViewItem.kf.setImage(with:  URL(string: obj.item?.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))

        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        destVC.item_offer_id = listArray[indexPath.item].id ?? 0
        destVC.userId = listArray[indexPath.item].sellerID ?? 0
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
    }
    
}


