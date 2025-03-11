//
//  SellingChatVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit

class SellingChatVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.register(UINib(nibName: "ChatListTblCell", bundle: nil), forCellReuseIdentifier: "ChatListTblCell")
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getChatList()

    }

    func getChatList(){
        
//    "type": "seller"  // or buyer
        let params = ["page":1,"type":"seller"] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.chatList.rawValue, params)
     
    }

}


extension SellingChatVC:UITableViewDelegate,UITableViewDataSource{
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTblCell") as! ChatListTblCell
        
        return cell
        
        
    }
    
    
}


