//
//  BannerAlalyticsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/07/25.
//

import SwiftUI

struct BannerAlalyticsView: View {
    
    var navigationController:UINavigationController?
    let  bannerId:Int
    @State private var objBanner:AnalyticsModel?
    
    var body: some View {
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Banner analytics").font(.manrope(.bold, size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            
            
            Button {
                pushToEditBanner()
            } label: {
                
                Text("Edit")
                    .font(.manrope(.semiBold, size: 16))
                            .foregroundColor(Color.orange).frame(width: 70,height: 25)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color(hexString: "#f6f5fa"))
                            //.cornerRadius(8)
                            .clipShape(Capsule())
                            
            }.padding(.horizontal)

          
         }.frame(height:44).background(Color(UIColor.systemBackground))
        
            .onAppear {
                getBannerAnanlytics()
            }
        
        ScrollView{
            VStack(alignment: .leading,spacing: 10){
               // Text("Banner image").font(.manrope(.bold, size: 20.0))
                AsyncImage(url: URL(string: objBanner?.image ?? "")) { img in
                    img.resizable().frame(maxWidth:.infinity,maxHeight: 130).cornerRadius(10)
                } placeholder: {
                    Image("getkartplaceholder")
                        .frame(maxWidth:.infinity,maxHeight: 130)
                }

            //    Image("getkartplaceholder")
                    .frame(maxWidth:.infinity,maxHeight: 130)
                HStack{
                    Spacer()
                    Text(getFormattedCreatedDate(date:objBanner?.startDate ?? ""))
                    Spacer()
                }
                
                if (objBanner?.rejectionReason?.count ?? 0) > 0{
                    Text(objBanner?.rejectionReason ?? "").foregroundColor(Color(.systemRed)).font(.manrope(.regular, size: 16.0))
                }
               
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add URL")
                        .font(.manrope(.semiBold, size: 16.0))
                    
                    Text(objBanner?.url ?? "")
                        .font(.manrope(.regular, size: 14.0))
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55, alignment: .leading) // ✅ keeps text left-aligned
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                        )
                    
                    Text("Add your business page link and let users discover you in just one click.").font(.manrope(.regular, size: 12.0))

                }


                
                Divider()
                            
                Text("Overview")
             
                VStack(spacing:15){
                    
//                    BannerAnalyticCell(title: "Status", value: "\(objBanner?.status ?? "")", isActive: true)
                    
                    if (objBanner?.status ?? "").lowercased() == "active"{
                        BannerAnalyticCell(title: "Status", value: "", isActive: true)

                    }else{
                        BannerAnalyticCell(title: "Status", value: "\(objBanner?.status ?? "")", isActive: false)

                    }

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(.gray))
                    
                    BannerAnalyticCell(title: "No. of clicks", value: "\(objBanner?.clicks ?? 0)", isActive: false)
                    BannerAnalyticCell(title: "Impressions", value: "\(objBanner?.uniqueViews ?? 0)", isActive: false)
                    BannerAnalyticCell(title: "Click-through rate (CTR)", value: "\(objBanner?.ctr ?? "")", isActive: false)
                    BannerAnalyticCell(title: "Conversions", value: "\(objBanner?.conversions ?? "")", isActive: false)
                    BannerAnalyticCell(title: "Screen Appearance", value: "\(objBanner?.screenAppearance ?? "")", isActive: false)
                    BannerAnalyticCell(title: "Radius", value: "\(objBanner?.radius ?? 0)km", isActive: false)
                   //BannerAnalyticCell(title: "Time to Click", value: "5sec.", isActive: false)
                    BannerAnalyticCell(title: "Location", value: "\(objBanner?.location ?? "")", isActive: false)
                    
                }.padding()
                    .background(Color(.systemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8.0).strokeBorder(Color(.gray),lineWidth: 0.5)
                    }
            }
        }.padding()
        
        .background(Color(.systemGray6))
    }
    
    
    func pushToEditBanner(){
        let destVC = UIHostingController(rootView: EditBanerPromotionView(navigationController: self.navigationController,objBanner:objBanner))
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    func getBannerAnanlytics(){
        
       let strUrl = Constant.shared.banner_analytics + "/\(bannerId)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl ) { (obj:AnalyticsParse) in
            
            if obj.code == 200{
                self.objBanner = obj.data
            }
        }
    }
    
    func getFormattedCreatedDate(date:String) -> String{
        
        
        //        let isoDateString = date
        //
        //        let isoFormatter = DateFormatter()
        //        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        //        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        //
        //        if let date = isoFormatter.date(from: isoDateString) {
        //            let outputFormatter = DateFormatter()
        //            outputFormatter.dateFormat = "dd MMM yyyy"
        //            let formattedDate = outputFormatter.string(from: date)
        //            return formattedDate
        //        } else {
        //            print("Invalid date string")
        //            return ""
        //        }
        //    }
        //
        //
        //    import Foundation
        
        let input = date
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.timeZone = .current
        
        if let date = inputFormatter.date(from: input) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMMM yyyy 'at' h:mm a"
            outputFormatter.amSymbol = "am"
            outputFormatter.pmSymbol = "pm"
            
            let formatted = outputFormatter.string(from: date)
            
            // Add ordinal suffix (st, nd, rd, th)
            let day = Calendar.current.component(.day, from: date)
            let suffix: String
            switch day {
            case 1, 21, 31: suffix = "st"
            case 2, 22:     suffix = "nd"
            case 3, 23:     suffix = "rd"
            default:        suffix = "th"
            }
            
            // Insert suffix after day number
            let final = formatted.replacingOccurrences(of: "^\(day)", with: "\(day)\(suffix)", options: .regularExpression)
            print(final) // 👉 "3rd November 2025 at 6:59 am"
            
            return final
        }
        
        return date

    }
    
    
}

//#Preview {
//    BannerAlalyticsView()
//}

struct BannerAnalyticCell:View {
  
    let title:String
    let value:String
    let isActive:Bool
    
    var body: some View {
        HStack{
            Text(title)
            Spacer(minLength: 60)
            if isActive{
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Active")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }.frame(width:90, height:26)
                    .background(Color(.green).opacity(0.4).cornerRadius(13.0))
                    .overlay {
                    RoundedRectangle(cornerRadius: 13).stroke(Color(.green).opacity(0.4),lineWidth: 0.1)
                    }.clipped()

            }
            Text(value)
        }
    }
}
