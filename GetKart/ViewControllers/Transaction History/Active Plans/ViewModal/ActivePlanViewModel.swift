//
//  ActivePlanViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/01/26.
//

import Foundation


final class ActivePlanViewModel:ObservableObject{
     var page = 1
    @Published var transactions = [TransactionModel]()
    @Published  var isDataLoading = false
    
    init(){
        getTransactionHistory()
    }
    
    
    func getTransactionHistory(){
        if isDataLoading{
            return
        }
        isDataLoading = true
        let strURl = "\(Constant.shared.get_active_plans)?page=\(page)&payment_status=succeed"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: (self.page == 1), url: strURl) { (obj:TransactionParse) in
            if obj.code == 200 {
                
                if self.page == 1{
                    self.transactions.removeAll()
                }
                   
                self.transactions.append(contentsOf: obj.data?.data ?? [])
                
                
                /*
                var arr = obj.data?.data ?? []
                // At loading time
                for i in 0..<arr.count {
                    if arr[i].id == nil {
                        let step = 10
                        let randomStepped = Int.random(in: 10...1000) * step
                        arr[i].id = randomStepped
                    }
                }
                self.transactions.append(contentsOf: arr)
                */
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.page += 1
                    self.isDataLoading = false
                })
            }else{
                self.isDataLoading = false

            }
        }
    }
}
