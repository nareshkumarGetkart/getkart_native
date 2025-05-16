//
//  TransactionHistoryPreview.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 21/04/25.
//

import SwiftUI

struct TransactionHistoryPreview: View {
    
    let transaction: TransactionModel?
    var navController:UINavigationController?
    
  var body: some View {
      
      navigationHeader() .frame(height: 44)

        VStack(spacing: 0) {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                 
                    VStack{
                        
                        Image("success")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.vertical, 5)
                        
                        Text("Payment successful")
                            .font(.title2)
                            .bold()
                        
                        Text("Successfully paid \(Local.shared.currencySymbol) \( (transaction?.paymentTransaction?.amount ?? 0.0).formatNumber())")
                            .foregroundColor(.gray)
                            .font(Font.manrope(.regular, size: 16.0))

                        
                        HStack{ }.frame(height:10)
                    }
                    
                    HStack{
                        Text("Payment methods")
                            .font(Font.manrope(.bold, size: 16.0))
                        Spacer()
                    }

                    detailsCard()
                    
                    Button(action: {}) {
                        Text("Total Cost \(Local.shared.currencySymbol) \((transaction?.paymentTransaction?.amount ?? 0.0).formatNumber())")
                            .font(Font.manrope(.bold, size: 18.0))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(24)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            .padding([.horizontal,.top],10)
            .cornerRadius(10)
            .background(Color(.systemGray6))
            
        }.navigationBarHidden(true)
        //.padding(.top)
    }

    
    @ViewBuilder
    private func detailRow(title: String, value: String, isCopyable: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(Font.manrope(.medium, size: 16.0))
                .foregroundColor(.gray)
            Spacer()
            HStack(spacing: 4) {
               
                if isCopyable {
                  
                    Image("ic_baseline-content-copy")
                        .font(.subheadline)
                        .foregroundColor(.gray).onTapGesture {
                            UIPasteboard.general.string = transaction?.paymentTransaction?.orderID ?? ""
                            AlertView.sharedManager.showToast(message: "Copied successfully")
                        }
                }
                Text(value).multilineTextAlignment(.trailing)
                    .font(Font.manrope(.semiBold, size: 16.0))
            }
        }
    }
    
    
    
    func getConvertedDateFromDate(date:Date) -> String{
        let dateFormatter = DateFormatter()
       
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: date)

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







@ViewBuilder
private func navigationHeader() -> some View {
    HStack {
        Button(action: {
            navController?.popViewController(animated: true)
        }) {
            Image("arrow_left")
                .renderingMode(.template)
                .foregroundColor(.black)
                .padding()
        }
        Text("Transaction History")
            .font(.custom("Manrope-Bold", size: 20.0))
            .foregroundColor(.black)
        Spacer()
    }
    .frame(height: 44)
}



@ViewBuilder
private func detailsCard() -> some View {
    VStack(spacing: 12) {
        let date = Date(timeIntervalSince1970: TimeInterval(convertTimestamp(isoDateString: transaction?.paymentTransaction?.createdAt ?? "")))

        detailRow(title: "Name", value: "\(transaction?.package?.name ?? "")")
        detailRow(title: "Category", value:"\(transaction?.package?.category ?? "")")
        detailRow(title: "Location", value: "\(transaction?.paymentTransaction?.city ?? "")")
        detailRow(title: "Bought pack", value: "\(transaction?.package?.itemLimit ?? "") Ads")

        detailRow(title: "Transaction ID", value: transaction?.paymentTransaction?.orderID ?? "", isCopyable: true)
        detailRow(title: "Date", value: getConvertedDateFromDate(date: date))
        detailRow(title: "Purchase from", value: "\(transaction?.paymentTransaction?.paymentGateway?.capitalized ?? "")")
//        detailRow(title: "Package validity", value: "\(transaction?.totalLimit ?? 0) days")
        
        detailRow(title: "Package validity", value: "\(transaction?.package?.duration ?? "") days")

        
        if (transaction?.remainingDays ?? "") ==  "0" {
            HStack {
                Text("Expires after")
                    .foregroundColor(.gray)
                Spacer()
                Text("Expired")
                    .foregroundColor(.red)
            }
        } else {
            detailRow(title: "Expires after", value: "\(transaction?.remainingDays ?? "") days")
        }

        HStack {
            Text("Active Ads")
                .foregroundColor(.green)
            Spacer()
            Text("\(transaction?.usedLimit ?? 0) Ads")
                .foregroundColor(.primary)
        }

        HStack {
            Text("Remaining Ads")
                .foregroundColor(.orange)
            Spacer()
            Text("\(transaction?.remainingItemLimit ?? 0) Ads")
                .foregroundColor(.primary)
        }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(16)
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color(hex:"#DADADA"), lineWidth: 0.5)
    )
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    //.padding(.horizontal)
}


}

#Preview {
    TransactionHistoryPreview(transaction: nil)
}
