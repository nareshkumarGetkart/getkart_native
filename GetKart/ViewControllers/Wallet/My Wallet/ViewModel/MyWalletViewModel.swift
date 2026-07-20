//
//  MyWalletViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/07/26.
//

import Foundation


class MyWalletViewModel:ObservableObject{
    
    @Published var walletObj:WalletModal?
    
     init(){
         getMyWalletBalance()
     }
    
    func getMyWalletBalance(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_wallet_balance) { (obj:WalletResponse) in
            
            if obj.code == 200{
                
                self.walletObj = obj.data
            }
        }
    }
}
