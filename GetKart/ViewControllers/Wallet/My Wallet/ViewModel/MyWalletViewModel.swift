//
//  MyWalletViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/07/26.
//

import Foundation


class MyWalletViewModel:ObservableObject{
    
    @Published var balance:String = "0"
    
     init(){
         getMyWalletBalance()
     }
    
    func getMyWalletBalance(){
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.get_wallet_balance, param: nil, methodType:.get, showLoader: true) {[weak self] responseObject, error in
            
            if error == nil{
                
                if let result = responseObject{
                    if let data = result["data"] as? Dictionary<String,Any>{
                        self?.balance = data["balance"] as? String ?? "0"
                        let  total_added = data["total_added"] as? String ?? "0"
                    }
                }
            }else{
                
            }
            
        }
        
    }
}
