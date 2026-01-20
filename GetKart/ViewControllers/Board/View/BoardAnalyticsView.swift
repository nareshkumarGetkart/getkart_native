//
//  BoardAnalyticsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/12/25.
//

import SwiftUI
import FittedSheets
import Kingfisher

struct BoardAnalyticsView: View {
    
    var navigationController:UINavigationController?
    let  boardId:Int
    @State private var objAnalytics:BoardAnalyticModel?
    @State private var showSheetpackages = false
    @State private var selectedPkgObj:PlanModel?
    @State private var paymentGateway: PaymentGatewayCentralized?

    //'draft','approved','paused','expired','rejected','pending'
    
    @State var isFromBoostPopup:Bool = false
    
    var body: some View {
        HStack(spacing:5){
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Board analytics").font(.inter(.medium, size: 18.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            
          
                
                Button {
                    pushToEditBanner()
                    
                } label: {
            
                    Image("editWithBg")
                    
                }
                Button {
                    openActionSheet()
                } label: {
                    
                    Image("more").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    
                }.padding(.trailing)
            
         }.frame(height:44).background(Color(UIColor.systemBackground))
        
            .onAppear {
            getBoardAnanlytics()
                
            }
        
        ScrollView{
            VStack(alignment: .leading,spacing: 15){
      
                
                HStack{
                    
                    Spacer()
                    VStack{
                        Text("Board image").font(.inter(.medium, size: 18.0))
                        KFImage(URL(string: objAnalytics?.board?.image ?? ""))
                            .placeholder {
                                Image("getkartplaceholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 230, height:280)
                                    .clipped() //  Important to crop overflowing area
                                    .cornerRadius(8)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 230, height:280)
                            .clipped()
                            .cornerRadius(8)
                        
                        Text(getFormattedCreatedDate(date:objAnalytics?.board?.createdAt ?? "")).font(.inter(.regular, size: 14.0)).foregroundColor(Color(.gray))

                    }

                    
                    Spacer()
                }.padding(.top)
 
                if (objAnalytics?.board?.rejectionReason?.count ?? 0) > 0{
                    Text(objAnalytics?.board?.rejectionReason ?? "").foregroundColor(Color(.systemRed)).font(.inter(.regular, size: 16.0))
                }
               
                if (objAnalytics?.board?.outbondURL ?? "").count > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Board URL")
                            .font(.inter(.semiBold, size: 16.0))
                        
                        HStack{
                            
                            Text(objAnalytics?.board?.outbondURL ?? "").lineLimit(2)
                                .font(.inter(.regular, size: 15.0))
                            
                            Spacer()
                            Button {
                                
                                if var urlString = objAnalytics?.board?.outbondURL {
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
                        
                        Text("Add your business page link and let users discover you in just one click.").font(.inter(.regular, size: 11.0)).foregroundColor(Color(.gray))
                        
                    }
                    
                }
                
                Divider()
                            
                Text("Overview").font(.inter(.semiBold, size: 16.0))
             
                VStack(spacing:15){
                    
//                    BannerAnalyticCell(title: "Status", value: "\(objAnalytics?.status ?? "")", isActive: true)
                    
                    if (objAnalytics?.board?.isActive ?? 0) == 1 && (objAnalytics?.board?.status ?? "").lowercased() == "approved"{
                        BoardAnalyticCell(title: "Board Status", value: "", isActive: true)

                    }else{
                        let status = ((objAnalytics?.board?.status ?? "").lowercased() == "review") ? "Under review" : objAnalytics?.board?.status ?? ""
                        
                        BoardAnalyticWithStatusGrayCell(title: "Board Status", value: "\(status.capitalized )")
                    }
          
                    
                    GeometryReader { geometry in
                        Path { path in
                            path.move(to: .zero)
                            path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                        }
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                    }
                    .frame(height: 1.5)
                   
                    BoardAnalyticCell(title: "Impressions", value: "\(objAnalytics?.analytics?.impressions ?? 0)", isActive: false)

                    BoardAnalyticCell(title: "Board Clicks", value: "\(objAnalytics?.analytics?.clicks ?? 0)", isActive: false)
                    BoardAnalyticCell(title: "Favorites", value: "\(objAnalytics?.analytics?.favorites ?? 0)", isActive: false)
                    BoardAnalyticCell(title: "Outbound Click", value: "\(objAnalytics?.analytics?.outboundClicks ?? 0)", isActive: false)
                                      
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
                  
                
                if (objAnalytics?.board?.isFeature ?? false) == false && (objAnalytics?.board?.status ?? "").lowercased() == "approved"{
                 
                    Button(action: {
                        showSheetpackages = true
                    }) {
                        Text("Boost Now")
                            .font(.inter(.semiBold, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .background(Color(hexString: "#FF9900"))
                            .cornerRadius(27.5)
                    }
                    .buttonStyle(.plain)

               }

            }
        }.padding([.horizontal])
            .scrollIndicators(.hidden, axes: .vertical)
        
        .background(Color(.systemGray6))
        .sheet(isPresented: $showSheetpackages) {
            
            BoostBoardPlanView(categoryId:objAnalytics?.board?.categoryID ?? 0,packageSelectedPressed: { selPkgObj in
                self.showSheetpackages = false
                selectedPkgObj = selPkgObj
                paymentGatewayOpen()
            })
            
            .presentationDetents([.height(410)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(20)   // ✅ THIS

         
        }.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(NotificationKeys.refreshMyBoardsScreen.rawValue))) { notification in
            getBoardAnanlytics()
        }
    }
    
    
    func paymentGatewayOpen() {

        paymentGateway = PaymentGatewayCentralized()   // ✅ STRONG REFERENCE
        paymentGateway?.planObj = selectedPkgObj
        paymentGateway?.categoryId = objAnalytics?.board?.categoryID ?? 0
        paymentGateway?.itemId = objAnalytics?.board?.id ?? 0
        paymentGateway?.paymentFor = .boostBoard

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
            }
            
            // ✅ RELEASE
               self.paymentGateway = nil
        }

        paymentGateway?.initializeDefaults()
    }
    
    func pushToEditBanner(){
        let destVC = UIHostingController(rootView: CreateBoardView(navigationController: self.navigationController, isFromEdit: true, boardId: boardId))
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    func getBoardAnanlytics(){
        
       let strUrl = Constant.shared.get_board_analytics + "?board_id=\(boardId)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl ) { (obj:BoardAnalyticsParse) in
            
            if obj.code == 200{
                self.objAnalytics = obj.data
                
                if self.isFromBoostPopup{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.showSheetpackages = true
                        self.isFromBoostPopup = false
                    })
                }

            }else{
                
                AlertView.sharedManager.presentAlertWith(title: "", msg: obj.message as NSString, buttonTitles: ["Ok"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in
                    self.navigationController?.popViewController(animated: true)

                }
            }
        }
    }
    
    
    func openActionSheet(){
        
        let sheet = UIAlertController(
            title: "",
            message: nil,
            preferredStyle: .actionSheet
        )

        if (objAnalytics?.board?.status ?? "").lowercased() == "approved" || (objAnalytics?.board?.status ?? "").lowercased() == "inactive"{
            
            let strText = ((objAnalytics?.board?.isActive ?? 0) == 1) ? "Deactivate" : "Activate"
            sheet.addAction(UIAlertAction(title: strText, style: .default, handler: { action in
                
                if strText == "Deactivate"{
                    deactivateConfirmation()
                }else{
                    self.updateBoardStatus()

                }
            }))
        }
        
        sheet.addAction(UIAlertAction(title: "Remove", style: .default, handler: { action in
            AlertView.sharedManager.presentAlertWith(title: "Remove", msg: "Are you sure want to remove?" as NSString, buttonTitles: ["Cancel","Confirm"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in

                if index == 1{
                    deleteBoardApi()
                }
            }
        }))
       
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(sheet, animated: true)
    }
    
    func deactivateConfirmation(){
       
        AlertView.sharedManager.presentAlertWith(title: "Deactivate your board", msg: " Are you sure you want to deactivate this board? You can reactivate it anytime." as NSString, buttonTitles: ["Cancel","Confirm"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in

            if index == 1{
                updateBoardStatus()
            }
        }
        
       
    }
    
    func deleteBoardApi(){
        
        let params = ["id":boardId]
         
        URLhandler.sharedinstance.makeCall(url: Constant.shared.delete_board, param: params,methodType: .post,showLoader: true) { responseObject, error in
            
            if error == nil {
             let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshMyBoardsScreen.rawValue), object: nil, userInfo: nil)

                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in
                        self.navigationController?.popViewController(animated: true)

                    }
                    
               
                }else{
                    

                }
            }
        }
    }
    
    
    func updateBoardStatus(){
        /*
         --form 'board_id="126560"' \
         --form 'status="inactive"' // sold out,inactive,active'
         */
        
        let strText = ((objAnalytics?.board?.isActive ?? 0) == 1) ? "inactive" : "active"

        let params = ["board_id":boardId,"status":strText] as [String : Any]
         
        URLhandler.sharedinstance.makeCall(url: Constant.shared.update_board_status, param: params,methodType: .post,showLoader: true) { responseObject, error in
            
            if error == nil {
             let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshMyBoardsScreen.rawValue), object: nil, userInfo: nil)
                    
                    var obj =  self.objAnalytics?.board
                    obj?.isActive = ((objAnalytics?.board?.isActive ?? 0) == 1) ? 0 : 1
                    self.objAnalytics?.board = obj
                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: AppDelegate.sharedInstance.navigationController!.topViewController!) { title, index in
                        self.navigationController?.popViewController(animated: true)

                    }
                    
               
                }else{
                    

                }
            }
        }
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

#Preview {
    BoardAnalyticsView(boardId: 234234)
}



struct BoardAnalyticCell:View {
  
    let title:String
    let value:String
    let isActive:Bool
    
    var body: some View {
        HStack{
            Text(title).font(.inter(.medium, size: 16.0)).foregroundColor(Color(.darkGray))
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
                Text(value).font(.inter(.semiBold, size: 16.0))
            }
        }
    }
}


struct BoardAnalyticWithStatusGrayCell:View {
    
    let title:String
    let value:String
    
    var body: some View {
        HStack{
            Text(title)
            Spacer(minLength: 60)
            HStack(spacing: 6) {
                
                Text(value)
                    .padding([.leading,.trailing],7).font(.inter(.semiBold, size: 14))
                    .foregroundColor(Color(.label))
            }.frame(height:26)
                .background(Color(.gray).opacity(0.4).cornerRadius(13.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 13).stroke(Color(.gray).opacity(0.4),lineWidth: 0.1)
                }.clipped()
            
            
        }
    }
}
