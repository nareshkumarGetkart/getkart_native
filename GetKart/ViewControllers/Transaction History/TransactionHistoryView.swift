//
//  TransactionHistoryView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI

struct TransactionHistoryView: View {
    
    var  navigation:UINavigationController?
    @State private var page = 1
    @State var transactions = [TransactionModel]()
    @State private var isDataLoading = false

    var body: some View {
        HStack {
         
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Text("Order History").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
        }.frame(height: 44)
               
        
        
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

                    HStack{ Spacer() }.frame(height: 5)
                    LazyVStack(spacing: 15) {
                        ForEach(transactions,id: \.id) { transaction in
                            TransactionRow(transaction: transaction)//.background((Color(UIColor.systemBackground)))
                                //.cornerRadius(10)
                                //.shadow(radius: 2)
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
                        
                     //  Spacer()
                    }
                   

                }.refreshable {
                    if isDataLoading == false {
                        self.page = 1
                        getTransactionHistory()
                    }
                }
            }
                        
        }.padding([.leading,.trailing],10).background(Color(.systemGray6))
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
        }
    }
    
    func getTransactionHistory(){
        if isDataLoading{
            return
        }
        isDataLoading = true
        let strURl = "\(Constant.shared.payment_transactions)?page=\(page)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strURl) { (obj:TransactionParse) in
            if obj.code == 200 {
                
                if self.page == 1{
                    self.transactions.removeAll()
                }
//                self.transactions.append(contentsOf: obj.data?.data ?? [])
                
                
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
    TransactionHistoryView(navigation:nil)
}




struct TransactionHistoryCell:View {
    var body: some View {
        VStack{
            
        }
    }
}



struct TransactionRow: View {
    let transaction: TransactionModel
    
    var body: some View {
        HStack {
            
            AsyncImage(url: URL(string: transaction.package?.icon ?? "")) { img in
                
                img.resizable().aspectRatio(contentMode: .fit).frame(width:60,height: 60)
                    .background(Color(hex: "#FEF6E9")).cornerRadius(6)
            } placeholder: {
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit).frame(width:60,height: 60).background(Color(hex: "#FEF6E9")).cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 2) {
                
                Text(transaction.package?.name ?? "")
                    .font(Font.manrope(.medium, size: 16))
                    .foregroundColor(Color(UIColor.label))
                
                Text("Purchased from \(transaction.paymentTransaction?.paymentGateway?.capitalized ?? "")" )
                    .font(Font.manrope(.regular, size: 16))
                    .foregroundColor(Color(UIColor.label))

                Button(action: {
                    UIPasteboard.general.string = transaction.paymentTransaction?.orderID
                    AlertView.sharedManager.showToast(message: "Copied successfully")

                }) {
                    Text("Transaction ID").font(Font.manrope(.regular, size: 13)).foregroundColor(.gray)
                    Image("ic_baseline-content-copy")
                        .renderingMode(.template)
                        .frame(width: 10, height: 10, alignment: .center)
                        .foregroundColor(.gray).padding(.leading,10)
                }
                
                Text(transaction.paymentTransaction?.orderID ?? "")
                    .font(Font.manrope(.regular, size: 13))
                    .foregroundColor(Color(UIColor.label))
                
            }.padding(5)
            Spacer()
            
           

            VStack(alignment: .trailing){
                
                Text("\(Local.shared.currencySymbol) \((transaction.paymentTransaction?.amount ?? 0.0).formatNumber())")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.label)).padding(.trailing,10)
                let status = transaction.paymentTransaction?.paymentStatus ?? ""
               
                let (bgColor, titleColor, displayStatus) = statusColors(for: status)

                Text(displayStatus.capitalized)
                    .font(Font.manrope(.medium, size: 15))
                    .foregroundColor(titleColor)
                    .padding(.horizontal)
                    .frame(height: 30)
                    .background(bgColor)
                    .cornerRadius(15)
                
                
                let date = Date(timeIntervalSince1970: TimeInterval(self.convertTimestamp(isoDateString: transaction.paymentTransaction?.createdAt ?? "")))
             
                
                Text(getConvertedDateFromDate(date: date))
                    .foregroundColor(.gray).padding(.trailing,10)
                
                Text(getConvertedTimeFromDate(date: date))
                    .foregroundColor(.gray).padding(.trailing,10)
                
            }
        }
        .padding([.top,.bottom,.horizontal],10)
//        .background(Color(UIColor.systemBackground))//.cornerRadius(10)
//        .clipped()
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color(UIColor.separator), lineWidth: 1.0)
//        )
//        
        
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.separator), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        //.shadow(color: Color(UIColor.label).opacity(0.05), radius: 5, x: 0, y: 2)
        
    }
    
    
    func getConvertedTimeFromDate(date:Date) -> String{
        let dateFormatter = DateFormatter()
       
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)

    }
    
    func getConvertedDateFromDate(date:Date) -> String{
        let dateFormatter = DateFormatter()
       
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date)

    }
    

    func statusColors(for status: String) -> (Color, Color, String) {
        switch status {
        case "succeed":
            return (Color(hexString: "#e5f7e7"), Color(hexString: "#32b983"), status)
        case "failed":
            return (Color(hexString: "#ffe5e6"), Color(hexString: "#fe0002"), status)
        case "canceled", "pending":
            return (Color(hexString: "#fff8eb"), Color(hexString: "#ffbb34"), status)
        default:
            return (.clear, .black, status)
        }
    }
    
    
    func convertTimestamp(isoDateString:String) -> Int64 {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC time
        
        if let date = isoFormatter.date(from: isoDateString) {
            // print("Converted Date:", date)
            
            let timestamp = Int64(date.timeIntervalSince1970) // Convert to seconds
            
            // print("Timestamp from ISO Date:", timestamp)
            return timestamp
            
            
        } else {
            
            print("Invalid date format")
            return 0
        }
    }
    

}
