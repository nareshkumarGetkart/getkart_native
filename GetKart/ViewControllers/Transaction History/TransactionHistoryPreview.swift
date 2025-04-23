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
        VStack(spacing: 0) {
            navigationHeader()
            
            ScrollView {
                VStack(spacing: 16) {
                 
                    VStack{
                        
                        Image("success")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.vertical, 5)
                        
                        Text("Payment successful")
                            .font(.title2)
                            .bold()
                        
                        Text("Successfully paid \(Local.shared.currencySymbol) \(String(format: "%.2f", transaction?.paymentTransaction?.amount ?? 0.0))")
                            .foregroundColor(.gray)
                        
                        HStack{ }.frame(height:10)
                    }
                    
                    HStack{
                        Text("Payment methods")
                        .font(.title3)
                        .bold()
                        Spacer()
                    }

                    detailsCard()
                    
                    Button(action: {}) {
                        Text("Total Cost \(Local.shared.currencySymbol) \(String(format: "%.2f", transaction?.paymentTransaction?.amount ?? 0.0))")
                            .bold()
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
        }
        .padding(.top)
    }

    
    @ViewBuilder
    private func detailRow(title: String, value: String, isCopyable: Bool = false) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            HStack(spacing: 4) {
                Text(value)
                    .bold()
                if isCopyable {
                    
                    Image("ic_baseline-content-copy")
                        .font(.caption)
                        .foregroundColor(.gray).onTapGesture {
                            UIPasteboard.general.string = transaction?.paymentTransaction?.orderID ?? ""
                            AlertView.sharedManager.showToast(message: "Copied successfully")
                        }
                }
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
    VStack(spacing: 16) {
        let date = Date(timeIntervalSince1970: TimeInterval(convertTimestamp(isoDateString: transaction?.paymentTransaction?.createdAt ?? "")))

        detailRow(title: "Name", value: "\(transaction?.package?.name ?? "")")
        detailRow(title: "Bought pack", value: "\(transaction?.package?.itemLimit ?? "") Days")
        detailRow(title: "Transaction ID", value: transaction?.paymentTransaction?.orderID ?? "", isCopyable: true)
        detailRow(title: "Date", value: getConvertedDateFromDate(date: date))
        detailRow(title: "Purchase from", value: "\(transaction?.paymentTransaction?.paymentGateway?.capitalized ?? "")")
        detailRow(title: "Package validity", value: "\(transaction?.totalLimit ?? 0) days")
        
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
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    //.padding(.horizontal)
}


}

#Preview {
    TransactionHistoryPreview(transaction: nil)
}
