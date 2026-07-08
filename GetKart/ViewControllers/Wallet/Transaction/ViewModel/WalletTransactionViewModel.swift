//
//  WalletTransactionViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/07/26.
//

import Foundation

class WalletTransactionViewModel:ObservableObject{
    var page = 1
    var listType:WalletFilterTab = .all
    @Published var transacrions = [WalletTransaction]()
    @Published var currentBalance: String = ""
    @Published var totalAdded: String = ""
    
    init(){
        getMyWalletBalance()
        getWalletHistory()
    }
    
    
    func callInitialLoading(){
        page = 1
        transacrions.removeAll()
        getWalletHistory()
    }
    
    func getWalletHistory(){
        
        var strUrl = Constant.shared.get_wallet_history + "?page=\(page)"
        
        if listType == .successful{
            strUrl.append("&status=success")
        }else if listType == .failed{
            strUrl.append("&status=failed")
        }else if listType == .pending{
            strUrl.append("&status=pending")
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:WalletHistoryResponse) in
            
            if obj.code == 200{
                if let arr = obj.data?.data{
                    self?.transacrions.append(contentsOf: arr)
                }
            }
        }
    }
    
    func getMyWalletBalance(){
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.get_wallet_balance, param: nil, methodType:.get, showLoader: true) {[weak self] responseObject, error in
            
            if error == nil{
                
                if let result = responseObject{
                    if let data = result["data"] as? Dictionary<String,Any>{
                        self?.currentBalance = data["balance"] as? String ?? "0"
                        self?.totalAdded = data["total_added"] as? String ?? "0"
                    }
                }
            }else{
                
            }
            
        }
        
    }
}
