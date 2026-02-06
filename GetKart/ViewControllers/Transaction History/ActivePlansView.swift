//
//  ActivePlansView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/01/26.
//

import SwiftUI

struct ActivePlansView: View {
    
    var  navigation:UINavigationController?
    
    @StateObject private var objViewmodel = ActivePlanViewModel()

    var body: some View {
        
        ScrollView{
            
            if objViewmodel.transactions.count == 0  && !objViewmodel.isDataLoading{
                
                HStack{
                    Spacer()
                    VStack(spacing: 30){
                        Spacer(minLength: 100)
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                LazyVStack(spacing:5){
                    
                    ForEach(objViewmodel.transactions,id: \.id) { transaction in
                        ActivePlansCell(transactionObj: transaction)
                            .onAppear{
                                
                                let lastId = objViewmodel.transactions.last?.id  ?? 0
                                let existingId = transaction.id ?? 0
                                if (lastId == existingId) && (objViewmodel.isDataLoading == false){
                                    objViewmodel.getTransactionHistory()
                                }
                            }
                    }
                    
                    Spacer()
                }.padding(5).padding(.top,5)
            }
        }.background(Color(.systemGray6))
            .refreshable {
                if objViewmodel.isDataLoading == false {
                    objViewmodel.page = 1
                    objViewmodel.getTransactionHistory()
                }
            }

    }
    

}

#Preview {
    ActivePlansView(navigation:nil)
}





struct ActivePlansCell:  View {
    let transactionObj:TransactionModel
    
    var body: some View {
        VStack(alignment:.leading,spacing:3){
            
            VStack(alignment:.leading,spacing:5){
                Text("Order ID: #\(String(transactionObj.id ?? 0))").font(.inter(.semiBold, size: 16.0))
                Text(transactionObj.package?.name ?? "").font(.inter(.medium, size: 12.0))
                //Text("Package availability").font(.inter(.medium, size: 12.0))
                
                if  transactionObj.package?.type == "board"{
                    //Board
                    Text("Package availability - \(transactionObj.package?.duration ?? "") days").font(.inter(.medium, size: 12.0))

                }else if transactionObj.package?.type == "campaign" {
                    //Banner
                    Text("Package availability").font(.inter(.medium, size: 12.0))
                } else {
                    //ads
                    Text("Package availability - \(transactionObj.package?.duration ?? "") days").font(.inter(.medium, size: 12.0))
                }
                
            }.padding(.horizontal).padding(.vertical,5).padding(.top,8)
            
            HStack{
                Spacer()

                VStack{
                    Text("Purchased").font(.inter(.medium, size: 10.0)).foregroundColor(Color(.systemGray))
                   // Text("1000").font(.inter(.medium, size: 12.0))
                    
                    if  transactionObj.package?.type == "board"{
                        //Board
                        Text("\(transactionObj.package?.itemLimit ?? "") clicks").font(.inter(.medium, size: 12.0))
                        
                    }else if transactionObj.package?.type == "campaign" {
                        //Banner
                        Text("\(transactionObj.package?.itemLimit ?? "") clicks").font(.inter(.medium, size: 12.0))
                    } else {
                        //ads
                        Text("\(transactionObj.package?.itemLimit ?? "") Ads").font(.inter(.medium, size: 12.0))
                    }
                   
                       
                }.padding(.vertical,8)
                Spacer()

                Divider().frame(height:30)
                Spacer()

                VStack{
                    Text("Remaining").font(.inter(.medium, size: 10.0)).foregroundColor(Color(.systemGray))
                    let itemLimit = Int(transactionObj.package?.itemLimit ?? "0") ?? 0
                    let usedlimit = Int(transactionObj.usedLimit ?? 0)
                    let remain = itemLimit - usedlimit
                    
                    if  transactionObj.package?.type == "board"{
                        //Board
                        Text("\(remain) clicks").font(.inter(.medium, size: 12.0))
                        
                    }else if transactionObj.package?.type == "campaign" {
                        //Banner
                        Text("\(remain) clicks").font(.inter(.medium, size: 12.0))
                    } else {

                       Text("\(remain) Ads").font(.inter(.medium, size: 12.0))

                    }
                }.padding(.vertical,8)
                Spacer()

                Divider().frame(height:30)
                Spacer()
                VStack{
                    Text("Current").font(.inter(.medium, size: 10.0)).foregroundColor(Color(.systemGray))
                    
                    if  transactionObj.package?.type == "board"{
                        //Board
                        Text("\(transactionObj.usedLimit ?? 0) clicks").font(.inter(.medium, size: 12.0))
                        
                    }else if transactionObj.package?.type == "campaign" {
                        //Banner
                        Text("\(transactionObj.usedLimit ?? 0) clicks").font(.inter(.medium, size: 12.0))
                    } else {
                        //ads
                        Text("\(transactionObj.usedLimit ?? 0) Ads").font(.inter(.medium, size: 12.0))
                        

                    }
                }.padding(.vertical,8)
                Spacer()


            }.background(Color(.systemOrange).opacity(0.2)).padding(.horizontal).padding(.vertical,5)
            
            VStack(spacing:5){
                HStack{
                    Text("Purchased on").font(.inter(.medium, size: 12.0))
                    Spacer()
                    //                    Text("Sep 10, 2025 at 08:25 PM").font(.inter(.regular, size: 12.0)).foregroundColor(Color(.systemGray))
                    Text(getFormattedCreatedDate(date: transactionObj.createdAt ?? "")).font(.inter(.regular, size: 12.0)).foregroundColor(Color(.systemGray))
                    
                }
                
                HStack{

                        Text("Expiring on").font(.inter(.medium, size: 12.0))
            Spacer()
          
                    
                    
                    if  transactionObj.package?.type == "board"{
                        //Board
                        Text("after \(transactionObj.package?.itemLimit ?? "0") clicks").font(.inter(.regular, size: 12.0)).foregroundColor(Color(.systemGray)) //Sep 10, 2025 at 08:25 PM
                        
                    }else if transactionObj.package?.type == "campaign" {
                        //Banner
                        Text("after \(transactionObj.package?.itemLimit ?? "0") clicks").font(.inter(.regular, size: 12.0)).foregroundColor(Color(.systemGray)) //Sep 10, 2025 at 08:25 PM
                    } else {
                        //ads
                        Text(getFormattedCreatedDate(date: transactionObj.endDate ?? "")).font(.inter(.regular, size: 12.0)).foregroundColor(Color(.systemGray)) //Sep 10, 2025 at 08:25 PM
                        

                    }
                    
                }
            }.padding(.horizontal).padding(.vertical,5).padding(.bottom,8)
            
        }.background(Color(.systemBackground)).cornerRadius(8.0).padding(.horizontal,5)
    }
    
    func getFormattedCreatedDate(date: String) -> String {

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC

        guard let parsedDate = isoFormatter.date(from: date) else {
            return date
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy 'at' h:mm a"
        outputFormatter.timeZone = TimeZone.current
        outputFormatter.amSymbol = "am"
        outputFormatter.pmSymbol = "pm"

        let formatted = outputFormatter.string(from: parsedDate)

        // Ordinal suffix logic
        let day = Calendar.current.component(.day, from: parsedDate)
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22:     suffix = "nd"
        case 3, 23:     suffix = "rd"
        default:        suffix = "th"
        }

        let final = formatted.replacingOccurrences(
            of: "^\(day)",
            with: "\(day)\(suffix)",
            options: .regularExpression
        )

        return final
    }
}


extension String {
    func hasDatePassed(format: String = "yyyy-MM-dd") -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        guard let date = formatter.date(from: self) else { return false }

        let cal = Calendar.current
        return cal.startOfDay(for: date)
            < cal.startOfDay(for: Date())
    }
}
