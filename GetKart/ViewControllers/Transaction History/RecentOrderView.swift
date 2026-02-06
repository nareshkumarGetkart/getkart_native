//
//  RecentOrderView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/01/26.
//

import SwiftUI

struct RecentOrderView: View {
    
    var  navigation:UINavigationController?
    @State private var page = 1
    @State var transactions = [TransactionModel]()
    @State private var isDataLoading = false
   
    var body: some View {
      /*  HStack {
         
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Text("Order History & Plans").font(Font.manrope(.medium, size: 18.0))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
        }.frame(height: 44)*/
                       
        VStack{
            if transactions.count == 0  && !isDataLoading{
                
                HStack{
                    Spacer()
                    VStack(spacing: 30){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                
                ScrollView(.vertical, showsIndicators: false) {

                    LazyVStack(spacing: 5) {
                        ForEach(transactions,id: \.id) { transaction in
                            TransactionRow(transaction: transaction)
                                .onAppear{
                                    
                                    let lastId = transactions.last?.id  ?? 0
                                    let existingId = transaction.id ?? 0
                                    if (lastId == existingId) && (isDataLoading == false){
                                        getTransactionHistory()
                                    }
                                }
                                .onTapGesture {
                                    self.pushToDesiredScreen(transObj: transaction)
                                    
                                }
                        }

                    }.padding(.top,8)
                   

                }.refreshable {
                    if isDataLoading == false {
                        self.page = 1
                        getTransactionHistory()
                    }
                }
            }
            
            if isDataLoading {
                ProgressView().padding(.vertical, 12)
            }
                        
        }.padding([.leading,.trailing],8).background(Color(.systemGray6))
            .onAppear{
                if transactions.count == 0{
                    getTransactionHistory()

                }
        }.navigationBarHidden(true)
        
    }
    
    
    func pushToDesiredScreen(transObj:TransactionModel){
        
        if (transObj.paymentTransaction?.paymentStatus ?? "") == "succeed"{
            let hostView = UIHostingController(rootView: TransactionHistoryPreview(transaction: transObj, navController: self.navigation))
            self.navigation?.pushViewController(hostView, animated: true)
        }else{
            AlertView.sharedManager.displayMessage(title: "Order Details", msg: "Order details are available only for successful orders!", controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        }
    }
    
    func getTransactionHistory(){
        if isDataLoading{
            return
        }
        isDataLoading = true
        let strURl = "\(Constant.shared.payment_transactions)?page=\(page)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: (self.page == 1), url: strURl) { (obj:TransactionParse) in
            if obj.code == 200 {
                
                if self.page == 1{
                    self.transactions.removeAll()
                }
              // self.transactions.append(contentsOf: obj.data?.data ?? [])
                
                
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

#Preview {
    RecentOrderView(navigation:nil)
}
