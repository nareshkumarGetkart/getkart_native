//
//  BannerAlalyticsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/07/25.
//

import SwiftUI
import FittedSheets

struct BannerAnalyticsView: View {
    
    var navigationController:UINavigationController?
    let  bannerId:Int
    @State private var objBanner:AnalyticsModel?
    @State private var selectedPkgObj:PlanModel?
    @State private var showSafari = false
    @State private var isToPreviewVideo = false
    @State private var showSheetpackages = false
    @State private var paymentGateway: PaymentGatewayCentralized?

    //'draft','approved','paused','expired','rejected','pending'
    
    var body: some View {
        VStack{
            HStack{
                Button {
                    navigationController?.popViewController(animated: true)
                    
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                Text("Banner analytics").font(.manrope(.bold, size: 18.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
                
                if (objBanner?.status ?? "") == "completed" {
                    Button {
                        deleteConfirmation()
                        
                    } label: {
                        
                        Image("remove")
                        
                    }.padding(.horizontal)
                }
                
                if (objBanner?.status ?? "") != "completed" {
                    
                    Button {
                        pushToEditBanner()
                    } label: {
                        
                        Image("editWithBg")
                        
                    }.padding(.horizontal)
                    
                }
            }.frame(height:44).background(Color(UIColor.systemBackground)).zIndex(1)
            
                .onAppear {
                    getBannerAnanlytics()
                }
            
            ScrollView{
                VStack(alignment: .leading,spacing: 10){
                    
                    if let img = objBanner?.thumbnail, img.count>0{
                        ZStack(alignment:.topLeading){
                            AsyncImage(url: URL(string: img)) { img in
                                img.resizable().aspectRatio(contentMode: .fill).frame(maxWidth:.infinity,minHeight:170, maxHeight: 170).cornerRadius(10)
                            } placeholder: {
                                Image("getkartplaceholder")
                                    .frame(maxWidth:.infinity,maxHeight: 170)
                            } .frame(maxWidth:.infinity,minHeight:170, maxHeight: 170)
                            
                            Button {
                                isToPreviewVideo = true
                            } label: {
                                Text("Preview")
                                    .padding(5).font(.inter(.regular, size: 14.0))
                                    .frame(width:75,height:26)
                                    .foregroundColor(Color(.white))
                            }
                            .background(Color(.darkGray))
                            .cornerRadius(13.0)
                            .clipped()
                            .padding([.leading,.top],8)
                        }
                    }else{
                        AsyncImage(url: URL(string: objBanner?.image ?? "")) { img in
                            img.resizable().frame(maxWidth:.infinity,minHeight:170, maxHeight: 170).cornerRadius(10)
                        } placeholder: {
                            Image("getkartplaceholder")
                                .frame(maxWidth:.infinity,maxHeight: 170)
                        } .frame(maxWidth:.infinity,minHeight:170, maxHeight: 170)
                    }
                    
                    
                    HStack{
                        Spacer()
                        Text(convertServerDateTime(objBanner?.startDate ?? ""))
                        Spacer()
                    }
                    
                    
                    if (objBanner?.status ?? "") == "draft" {
                        
                        Text("Your banner is still in draft.Please complete the required details to publish it.").multilineTextAlignment(.center).foregroundColor(Color(.systemRed)).font(.manrope(.regular, size: 16.0))
                        
                    }
                    
                    //  if (objBanner?.rejectionReason?.count ?? 0) > 0{
                    
                    if ((objBanner?.rejectionReason?.count ?? 0) > 0)  && ((objBanner?.status?.lowercased() ?? "") == "rejected"){
                        
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
                                    showSafari = true
                                    
                                } label: {
                                    Image("globe")
                                }
                                
                            }.padding(.horizontal)
                                .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemBackground))
                                )
                            
                            Text("Add your business page link and let users discover you in just one click.").font(.manrope(.regular, size: 12.0))
                            
                        }
                        
                    }
                    
                    Divider()
                    
                    Text("Overview")
                    
                    VStack(spacing:15){
                        
                        if (objBanner?.isActive ?? 0) == 1{
                            BannerAnalyticCell(title: "Status", value: "", isActive: true)
                            
                        }else{
                            BannerAnalyticWithStatusGrayCell(title: "Status", value: "\(objBanner?.status?.capitalized ?? "")")
                        }
                        
                        
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
                        BannerAnalyticCell(title: "Screen Appearance", value: "\(objBanner?.screenAppearance ?? "")", isActive: false)
                        
                        
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
                            .background(Color(hexString: "#FF9900")) .cornerRadius(12)//.padding(.bottom)
                    }
                    
                }.padding([.top])
            }.padding([.horizontal])
            .background(Color(.systemGray6))
        }
        .sheet(isPresented: $showSheetpackages) {
            if #available(iOS 16.0, *) {
          
                BannerPackageView(packageSelectedPressed: { selPkgObj, pymntMethod in
                    self.paymentGatewayOpen(selPlan: selPkgObj, selPaymentMethod: pymntMethod)
                })
                .presentationDetents([.fraction(0.7)]) //  50% screen height
                .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            }   //  Optional drag handle
        }
        
        .fullScreenCover(isPresented: $showSafari) {
            
            if let url = URL(string:getUrlValid(strURl: objBanner?.url ?? ""))  {
                
                SafariView(url:url)
            }
        }
        .fullScreenCover(isPresented: $isToPreviewVideo) {
          
            if let _ = URL(string:(objBanner?.image ?? "").getValidUrl())  {
           
                VideoPreviewView(item: nil,strURl: objBanner?.image ?? "")
            }
        }
    }
    
    func getUrlValid(strURl:String) ->String{
        var urlString = strURl
        if !urlString.lowercased().hasPrefix("http://") &&
            !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        return urlString
    }
    
    
    
    func paymentGatewayOpen(selPlan: PlanModel,selPaymentMethod:SelPaymentMethod) {
                
        paymentGateway = PaymentGatewayCentralized()   //  STRONG REFERENCE
        paymentGateway?.planObj = selPlan
        paymentGateway?.banner_id = objBanner?.id ?? 0
        paymentGateway?.categoryId = 0
        paymentGateway?.categoryName = ""
        paymentGateway?.paymentFor = .bannerPromotionDraft
        paymentGateway?.payment_transaction_id = objBanner?.paymentTransactions?.id ?? 0
        
        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in
           
            if isSuccess {
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(
                        navigationController: self.navigationController
                    )
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.present(vc, animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshBannerAdsScreen.rawValue), object: nil, userInfo: nil)
            }
            
            //  RELEASE
            self.paymentGateway = nil
        }
        paymentGateway?.initializeDefaults(selpaymentMethod: selPaymentMethod)
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
    
    func convertServerDateTime(_ dateString: String) -> String {

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        guard let date = isoFormatter.date(from: dateString) else {
            return dateString
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "d MMM yyyy 'at' h:mma"

        var formatted = formatter.string(from: date)

        // Add ordinal suffix
        let day = Calendar.current.component(.day, from: date)

        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }

        formatted = formatted.replacingOccurrences(
            of: "^\(day)",
            with: "\(day)\(suffix)",
            options: .regularExpression
        )

        return formatted.lowercased()
    }
    
    func getFormattedCreatedDate(date:String) -> String{

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
            print(final) //  "3rd November 2025 at 6:59 am"
            
            return final
        }
        
        return date

    }
    
}

//#Preview {
//    BannerAlalyticsView()
//}

