//
//  BannerAlalyticsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/07/25.
//

import SwiftUI
import FittedSheets

struct BannerAlalyticsView: View {
    
    var navigationController:UINavigationController?
    let  bannerId:Int
    @State private var objBanner:AnalyticsModel?
    @State private var showSheetpackages = false
    @State private var selectedPkgObj:PlanModel?

    //'draft','approved','paused','expired','rejected','pending'
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
            
            if (objBanner?.status ?? "") == "completed" { // || (objBanner?.status ?? "") == "draft"  {
                Button {
                  //  pushToEditBanner()
                    deleteConfirmation()
                    
                } label: {
                    
                  /*  Text("Edit")
                        .font(.manrope(.semiBold, size: 16))
                                .foregroundColor(Color.orange).frame(width: 70,height: 25)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color(hexString: "#f6f5fa"))
                                //.cornerRadius(8)
                                .clipShape(Capsule())*/
                    Image("remove")
                                
                }.padding(.horizontal)
            }
       
            if (objBanner?.status ?? "") != "completed" {
                
                Button {
                    pushToEditBanner()
                } label: {
                    
                    /*  Text("Edit")
                     .font(.manrope(.semiBold, size: 16))
                     .foregroundColor(Color.orange).frame(width: 70,height: 25)
                     .padding(.horizontal, 16)
                     .padding(.vertical, 6)
                     .background(Color(hexString: "#f6f5fa"))
                     //.cornerRadius(8)
                     .clipShape(Capsule())*/
                    Image("editWithBg")
                    
                }.padding(.horizontal)
                
            }
         }.frame(height:44).background(Color(UIColor.systemBackground))
        
            .onAppear {
                getBannerAnanlytics()
            }
        
        ScrollView{
            VStack(alignment: .leading,spacing: 10){
               // Text("Banner image").font(.manrope(.bold, size: 20.0))
                AsyncImage(url: URL(string: objBanner?.image ?? "")) { img in
                    img.resizable().frame(maxWidth:.infinity,minHeight:130, maxHeight: 130).cornerRadius(10)
                } placeholder: {
                    Image("getkartplaceholder")
                        .frame(maxWidth:.infinity,maxHeight: 130)
                }

            //    Image("getkartplaceholder")
                .frame(maxWidth:.infinity,minHeight:130, maxHeight: 130)
                HStack{
                    Spacer()
                    Text(getFormattedCreatedDate(date:objBanner?.startDate ?? ""))
                    Spacer()
                }
                
                
                if (objBanner?.status ?? "") == "draft" {
                 
                    Text("Your banner is still in draft.Please complete the required details to publish it.").multilineTextAlignment(.center).foregroundColor(Color(.systemRed)).font(.manrope(.regular, size: 16.0))

                }

                if (objBanner?.rejectionReason?.count ?? 0) > 0{
                    Text(objBanner?.rejectionReason ?? "").foregroundColor(Color(.systemRed)).font(.manrope(.regular, size: 16.0))
                }
               
                if (objBanner?.url ?? "").count > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Added URL")
                            .font(.manrope(.semiBold, size: 16.0))
                        
                        HStack{
                            
                            Text(objBanner?.url ?? "").lineLimit(2)
                                .font(.manrope(.regular, size: 15.0))
                            
                            Spacer()
                            Button {
                                
                                if var urlString = objBanner?.url {
                                    // Add scheme if missing
                                    if !urlString.lowercased().hasPrefix("http://") &&
                                        !urlString.lowercased().hasPrefix("https://") {
                                        urlString = "https://" + urlString
                                    }
                                    
                                    if let url = URL(string: urlString) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    } else {
                                        print("Invalid URL: \(urlString)")
                                    }
                                }

                            } label: {
                                Image("globe")//.frame(width: 40, height: 40)//.aspectRatio(contentMode: .fill)
                            }

                        }.padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55, alignment: .leading) // ✅ keeps text left-aligned
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                            )
                        /*  Text(objBanner?.url ?? "")
                         .font(.manrope(.regular, size: 14.0))
                         .padding(.horizontal)
                         .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55, alignment: .leading) // ✅ keeps text left-aligned
                         .background(
                         RoundedRectangle(cornerRadius: 8)
                         .fill(Color(.systemBackground))
                         )
                         */
                        Text("Add your business page link and let users discover you in just one click.").font(.manrope(.regular, size: 12.0))
                        
                    }
                    
                }
                
                Divider()
                            
                Text("Overview")
             
                VStack(spacing:15){
                    
//                    BannerAnalyticCell(title: "Status", value: "\(objBanner?.status ?? "")", isActive: true)
                    
                    if (objBanner?.isActive ?? 0) == 1{
                        BannerAnalyticCell(title: "Status", value: "", isActive: true)

                    }else{
                        BannerAnalyticWithStatusGrayCell(title: "Status", value: "\(objBanner?.status?.capitalized ?? "")")
                    }

//                    Rectangle()
//                        .frame(height: 1)
//                        .foregroundColor(.gray)
//                        .overlay(
//                            Rectangle()
//                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
//                                .foregroundColor(.gray))
                    
                    GeometryReader { geometry in
                        Path { path in
                            path.move(to: .zero)
                            path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                        }
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                    }
                    .frame(height: 1.5)

                    BannerAnalyticCell(title: "No. of clicks", value: "\(objBanner?.clicks ?? 0)", isActive: false)
                    BannerAnalyticCell(title: "Impressions", value: "\(objBanner?.uniqueViews ?? 0)", isActive: false)
                    BannerAnalyticCell(title: "Click-through rate (CTR)", value: "\(objBanner?.ctr ?? "")", isActive: false)
                   // BannerAnalyticCell(title: "Conversions", value: "\(objBanner?.conversions ?? "")", isActive: false)
                    BannerAnalyticCell(title: "Screen Appearance", value: "\(objBanner?.screenAppearance ?? "")", isActive: false)
                    BannerAnalyticCell(title: "Radius", value: "\(objBanner?.radius ?? 0)km", isActive: false)
                   //BannerAnalyticCell(title: "Time to Click", value: "5sec.", isActive: false)
                    BannerAnalyticCell(title: "Location", value: "\(objBanner?.location ?? "")", isActive: false)
                    
                }.padding()
                
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
                
                
                if (objBanner?.status ?? "") == "draft" {
                    
                    Button {
                        showSheetpackages = true
                    } label: {
                        
                        Text("Complete Now").font(.manrope(.medium, size: 16.0)).foregroundColor(.white)
                          
                    }.frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                         .background(Color(hexString: "#FF9900")) .cornerRadius(27.5)
                }

            }
        }.padding()
        
        .background(Color(.systemGray6))
        .sheet(isPresented: $showSheetpackages) {
            if #available(iOS 16.0, *) {
                PromotionPackagesView(navigationController: self.navigationController, packageSelectedPressed: {selPkgObj in
                    selectedPkgObj = selPkgObj
                    self.presentPayView(planObj: selPkgObj)
                    //showBuySheetpackages = true
                    
                    
                })
                .presentationDetents([.fraction(0.6)]) // 📏 50% screen height
                .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            }   // ⬆️ Optional drag handle
        }
    }
    
    func presentPayView(planObj:PlanModel){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "PayPlanVC")
        as! PayPlanVC
        controller.planObj = planObj
        controller.banner_id = objBanner?.id ?? 0
        controller.categoryId = 0
        controller.categoryName = ""
        controller.paymentFor = .bannerPromotionDraft
        controller.payment_transaction_id = objBanner?.paymentTransactions?.id ?? 0
       // controller.payment_transaction_id = objBanner?.
      /*  controller.radius = radius
        controller.area = area
        controller.selectedImage = selectedImage
        controller.city = city
        controller.country = country
        controller.state = state
        controller.latitude = "\(latitude)"
        controller.longitude = "\(longitude)"
        controller.strUrl = strUrl*/
        
        controller.callbackPaymentSuccess = { (isSuccess) -> Void in
            
            if controller.sheetViewController?.options.useInlineMode == true {
                controller.sheetViewController?.attemptDismiss(animated: true)
            } else {
                controller.dismiss(animated: true, completion: nil)
            }
            
            if isSuccess == true {
                let vc = UIHostingController(rootView: PlanBoughtSuccessView(navigationController: self.navigationController))
                vc.modalPresentationStyle = .overFullScreen // Full-screen modal
                vc.modalTransitionStyle = .crossDissolve   // Fade-in effect
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                self.navigationController?.present(vc, animated: true, completion: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshBannerAdsScreen.rawValue), object: nil, userInfo: nil)
            }
        }
        
        let useInlineMode = (self.navigationController?.topViewController?.view)! != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.3
        if UIDevice().hasNotch{
            fixedSize = 0.27
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.37
            }
        }
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.percent(Float(fixedSize)),.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
        sheet.allowGestureThroughOverlay = false
        // sheet.dismissOnOverlayTap = false
        sheet.cornerRadius = 15
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
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
            }else{
                
                AlertView.sharedManager.presentAlertWith(title: "", msg: obj.message as NSString, buttonTitles: ["Ok"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in
                    self.navigationController?.popViewController(animated: true)

                }
            }
        }
    }
    
    func deleteConfirmation(){
       
        AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to delete?" as NSString, buttonTitles: ["No","Ok"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in

            if index == 1{
                deleteBannersApi()
            }
        }
    }
    
    func deleteBannersApi(){
        
        let params = ["banner_id":bannerId]
         
        URLhandler.sharedinstance.makeCall(url: Constant.shared.delete_campaign_banner, param: params,methodType: .post,showLoader: true) { responseObject, error in
            
            if error == nil {
             let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshBannerAdsScreen.rawValue), object: nil, userInfo: nil)

                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in
                        self.navigationController?.popViewController(animated: true)

                    }
                    
               
                }else{
                    

                }
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
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Active")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }.frame(width:100, height:26)
                    .background(Color(.systemGreen).opacity(0.4).cornerRadius(13.0))
                    .overlay {
                    RoundedRectangle(cornerRadius: 13).stroke(Color(.systemGreen).opacity(0.4),lineWidth: 0.1)
                    }.clipped()

            }else{
                Text(value)
            }
        }
    }
}


struct BannerAnalyticWithStatusGrayCell:View {
  
    let title:String
    let value:String
    
    var body: some View {
        HStack{
            Text(title)
            Spacer(minLength: 60)
                HStack(spacing: 6) {
                 
                    Text(value)
                        .padding([.leading,.trailing],7).font(.manrope(.semiBold, size: 14))
                        .foregroundColor(Color(.label))
                }.frame(height:26)
                    .background(Color(.gray).opacity(0.4).cornerRadius(13.0))
                    .overlay {
                    RoundedRectangle(cornerRadius: 13).stroke(Color(.gray).opacity(0.4),lineWidth: 0.1)
                    }.clipped()

         
        }
    }
}
