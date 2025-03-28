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
    private var emptyView:EmptyList?
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.register(UINib(nibName: "ChatListTblCell", bundle: nil), forCellReuseIdentifier: "ChatListTblCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.chatList), name: NSNotification.Name(rawValue: SocketEvents.sellerChatList.rawValue), object: nil)
        
        DispatchQueue.main.async{
            self.emptyView = EmptyList(frame: CGRect(x: 0, y: 0, width:  self.tblView.frame.size.width, height:  self.tblView.frame.size.height))
            self.tblView.addSubview(self.emptyView!)
            self.emptyView?.isHidden = true
            self.emptyView?.lblMsg?.text = "No chat Found"
            self.emptyView?.imageView?.image = UIImage(named: "no_chat_found")
        }
        
        getChatList()

    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func getChatList(){
        
        //"type": "seller"  // or buyer
        let params = ["page":1,"type":"seller"] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.sellerChatList.rawValue, params)
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
            
            self.emptyView?.isHidden = (self.listArray.count) > 0 ? true : false
            self.emptyView?.lblMsg?.text = "No chat Found"
            self.emptyView?.subHeadline?.text = ""

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
        cell.imgViewProfile.kf.setImage(with:  URL(string: obj.buyer?.profile ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        cell.imgViewItem.kf.setImage(with:  URL(string: obj.item?.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        destVC.item_offer_id = listArray[indexPath.item].id ?? 0
        destVC.userId = listArray[indexPath.item].buyerID ?? 0
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
}


