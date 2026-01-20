//
//  MyBoardsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//

import SwiftUI
import Kingfisher

struct MyBoardsView: View {
    
    var navigationController:UINavigationController?
    @State private var listArray:Array<ItemModel> = [ItemModel]()
    @State private var page = 1
    @State private var isDataLoading = false
    @State private var paymentGateway: PaymentGatewayCentralized?
    @State private var hasMoreData = true
    @State private var hasUserScrolled = false

    var body: some View {
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
            } label: {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
            }
            
            Text("My Boards") .font(.inter(.medium, size: 18))
            Spacer()
            
        }.padding().frame(height:44)
        
        ScrollView{
            if listArray.count == 0 && !isDataLoading {
                HStack{
                    Spacer()
                    VStack(spacing: 20){
                        Spacer(minLength: 100)
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding(.top).padding(.horizontal)
                        Text("There are currently no boards available. Start by creating your first board now").font(Font.manrope(.regular, size: 16.0)).multilineTextAlignment(.center).padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    Spacer()
                }
            }else{
                
                LazyVStack(spacing:10){
                
                ForEach(listArray ,id: \.id) { myBroad in
                    MyBoardCell(itemObj: myBroad,onBoostTapped: { item, plan in
                        paymentGatewayOpen(selPlan: plan, item: item)
                    })
                    
                    .onTapGesture {
                        pushToBoardAnalytics(myBroad: myBroad)
                    }
                    .onAppear {
                        if myBroad.id == listArray.last?.id {
                            loadNextPageIfAllowed()
                        }
                    }
                }
                Spacer()
                
//                    if hasMoreData {
//                        Color.clear
//                            .frame(height: 1).hid
//                            .onAppear {
//                                loadNextPage()
//                            }
//                    }
                

            }.padding(8)
            
        }
        }.simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    hasUserScrolled = true   // ✅ REAL scroll detected
                }
        )
    .background(Color(.systemGray6))
            .refreshable {
                print("call api here")
                
                if !isDataLoading{
                    self.page = 1
                    getAdsListApi()
                }
            }
            .onAppear{
                if listArray.count == 0 {
                    self.page = 1
                    getAdsListApi()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(NotificationKeys.refreshMyBoardsScreen.rawValue))) { notification in
                self.page = 1
                getAdsListApi()
            }
    }
    
    
    func pushToBoardAnalytics(myBroad:ItemModel){
        
   
        let destVC = UIHostingController(rootView: BoardAnalyticsView(navigationController: self.navigationController, boardId: myBroad.id ?? 0))
        self.navigationController?.pushViewController(destVC, animated: true)
         
    }
    func loadNextPageIfAllowed() {
        guard
            hasUserScrolled,        // ✅ user actually scrolled
            !isDataLoading,
            hasMoreData
        else { return }

        getAdsListApi()
    }

    
    func loadMoreIfNeeded(currentItem: ItemModel) {
        guard
            currentItem.id == listArray.last?.id,
            !isDataLoading,
            hasMoreData
        else { return }

        isDataLoading = true
        getAdsListApi()
    }

    //MARK: Api methods
    func getAdsListApi() {
        guard !isDataLoading else { return }
        isDataLoading = true

        let strUrl = Constant.shared.get_my_board + "?page=\(page)"

        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: page == 1,
            url: strUrl,
            loaderPos: .mid
        ) { (obj: ItemParse) in

            DispatchQueue.main.async {
                let newItems = obj.data?.data ?? []

                if self.page == 1 {
                    self.listArray = newItems
                } else {
                    self.listArray.append(contentsOf: newItems)
                }

                self.hasMoreData = !newItems.isEmpty
                self.isDataLoading = false
                self.page += 1
            }
        }
    }

  /*  func getAdsListApi(){
        guard !isDataLoading else { return }
      
        self.isDataLoading = true
        
        if self.page == 1 {
            hasMoreData = true
            self.listArray.removeAll()
        }
        
        let strUrl = Constant.shared.get_my_board + "?page=\(page)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl,loaderPos: .mid) { (obj:ItemParse) in
            
            if obj.code == 200 {
                
              //  DispatchQueue.main.async {
                    let newItems = obj.data?.data ?? []
                    
                    if newItems.isEmpty {
                        self.hasMoreData = false
                    } else {
                        self.listArray.append(contentsOf: newItems)
                    }
                    self.isDataLoading = false
                    self.page += 1
              //  }
                
               /* if obj.data != nil , (obj.data?.data ?? []).count > 0 {
                    self.listArray.append(contentsOf:  obj.data?.data ?? [])
                }
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isDataLoading = false
                    self.page += 1
               })
                */
                
            }else{
                self.isDataLoading = false
            }
        }
    }
    */
    
    func paymentGatewayOpen(selPlan: PlanModel,item:ItemModel) {

        paymentGateway = PaymentGatewayCentralized()   // ✅ STRONG REFERENCE
        paymentGateway?.planObj = selPlan
        paymentGateway?.categoryId = item.categoryID ?? 0
        paymentGateway?.itemId = item.id ?? 0
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
}

#Preview {
    MyBoardsView(navigationController:nil)
}




struct MyBoardCell:View {
    let itemObj:ItemModel
    @State private var showBoostSheet = false
    var onBoostTapped: (_ item: ItemModel, _ plan: PlanModel) -> Void

    var body: some View {
        VStack(spacing:0){
            HStack{
                
                ZStack(alignment:.bottomLeading){
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 105,height: 120)
                        .cornerRadius(10)
                      //  .cornerRadius(10, corners: [.topRight, .bottomRight])
                    
                    KFImage(URL(string:  itemObj.image ?? ""))
                        .placeholder {
                            Image("getkartplaceholder")
                                .frame(width: 105,height: 120).aspectRatio(contentMode: .fit).cornerRadius(10)
                        }
                        .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
                                                                    height: widthScreen / 2.0 - 15))
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 105, maxHeight: 120).cornerRadius(10).clipped()//.padding(1)
                    
                    if (itemObj.isFeature ?? false) == true{
                      //  VStack(alignment:.leading){
                           HStack{
                               Spacer()
                                Text("Sponsered")
                                    .frame(height:22)
                                   // .background(.orange)
                                   // .cornerRadius(5)
                                    .foregroundColor(Color(.white))
                                    .font(.inter(.medium, size: 14))
                               Spacer()
                            } .background(.orange)//.padding(.top,5)
                            //Spacer()
                       // }
                    }
                }.frame(width: 105,height: 120).cornerRadius(10)
                
                
                VStack(alignment: .leading, spacing: 5){
                  
                    HStack{
                        
                        VStack(alignment:.leading){
                            if (itemObj.specialPrice ?? 0.0) > 0{
                                HStack{
                                    Text("\(Local.shared.currencySymbol) \((itemObj.specialPrice ?? 0.0).formatNumber())")
                                        .font(.inter(.medium, size: 18))
                                        .foregroundColor(Color(hex: "#008838"))
                                    
                                    Spacer()
                                    
                                    let (bgColor, titleColor, displayStatus) = statusColors(for: itemObj.status ?? "")
                                    
                                    Text(displayStatus.capitalized).font(Font.inter(.semiBold, size: 11))
                                        .foregroundColor(titleColor)
                                        .padding()
                                        .frame(height:24)
                                        .background(bgColor)
                                    
                                        .cornerRadius(12)
                                        .clipped()
                                        .padding(.trailing,5)
                                    
                                }
                              
                                HStack{
                                    Text("\(Local.shared.currencySymbol)\((itemObj.price ?? 0.0).formatNumber())")
                                        .font(.inter(.regular, size: 14))
                                        .foregroundColor(Color(.gray)).strikethrough(true, color: .secondary)
                                    let per = (((itemObj.price ?? 0.0) - (itemObj.specialPrice ?? 0.0)) / (itemObj.price ?? 0.0)) * 100.0
                                    Text("\(per.formatNumber())% Off").font(.inter(.medium, size: 12))
                                        .foregroundColor(Color(hex: "#008838"))
                                }
                                
                            }else{
                                
                                HStack{
                                    Text("\(Local.shared.currencySymbol) \((itemObj.price ?? 0.0).formatNumber())").multilineTextAlignment(.leading).font(Font.inter(.medium, size: 18)).foregroundColor(Color(hexString: "#008838"))
                                    
                                    Spacer()
                                    
                                    
                                    let (bgColor, titleColor, displayStatus) = statusColors(for: itemObj.status ?? "")
                                    
                                    Text(displayStatus.capitalized).font(Font.inter(.semiBold, size: 11))
                                        .foregroundColor(titleColor)
                                        .padding()
                                        .frame(height:24)
                                        .background(bgColor)
                                    
                                        .cornerRadius(12)
                                        .clipped()
                                        .padding(.trailing,5)
                                }
                            }
                        }
                    }
                    
                    Text(itemObj.name ?? "").lineLimit(1).multilineTextAlignment(.leading).font(Font.inter(.regular, size: 16)).foregroundColor(Color(UIColor.label))
                        .padding(.bottom,10)
                        .padding(.trailing)
                    
                    if (itemObj.address ?? "").count > 0{
                        HStack(spacing:4){
                            Image("location-outline")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                                .frame(width: 10, height: 10)
                            Text(itemObj.address ?? "").multilineTextAlignment(.leading).font(Font.inter(.regular, size: 13)).foregroundColor(.gray).padding(.trailing)
                            Spacer()
                        }
                    }
                    HStack(spacing:6){
                        
                        HStack(spacing:3){
                            Image("eye").resizable().renderingMode(.template).foregroundColor(.gray).frame(width: 13, height: 13)
                            Text("Views: \(itemObj.clicks ?? 0)").multilineTextAlignment(.leading).font(Font.inter(.regular, size: 11)).foregroundColor(.gray)//.padding(.trailing)
                        }
                        
                        HStack(spacing:3){
                            Image("heart").resizable().renderingMode(.template).foregroundColor(.gray).frame(width: 11, height: 11)
                            Text("Like: \(itemObj.totalLikes ?? 0)").multilineTextAlignment(.leading).font(Font.inter(.regular, size: 11)).foregroundColor(.gray)//.padding(.trailing)
                        }
                        Spacer()
                        Text("More Details").font(Font.inter(.medium, size: 14)).foregroundColor(Color(.systemOrange)).padding(.trailing,5)
                    }
                    
                }.padding(.horizontal,2)//.padding([.top,.bottom],10)
                
            }.frame(height: 120)
                .background(Color(UIColor.systemBackground)).cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#E0E8F299"), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            if (itemObj.status?.lowercased() ?? "") ==  "approved" && !(itemObj.isFeature ?? false){
                
                HStack{
                    Rectangle() .fill(Color.orange)
                        .frame(width: 4)
                        .cornerRadius(2)
                    Text("Boost your board to reach more buyers faster.").font(Font.inter(.regular, size: 12)).foregroundColor(Color(.label))
                    Spacer()
                    Button {
                        showBoostSheet = true
                    } label: {
                        Text("Boost Now").font(Font.inter(.semiBold, size: 12))
                            .foregroundColor(Color(.white))
                    }.frame(width: 80,height: 26).background(Color(.systemOrange))
                        .cornerRadius(5, antialiased: true)
                    
                } .padding(.horizontal,5).padding(.vertical,8)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(Color.orange.opacity(0.1))
                  .cornerRadius(8)
            }
            
        } .sheet(isPresented: $showBoostSheet) {
            BoostBoardPlanView(categoryId:itemObj.categoryID ?? 0,packageSelectedPressed: { selPkgObj in
                onBoostTapped(itemObj,selPkgObj)
            })//.cornerRadius(25)
            
            .presentationDetents([.height(410)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(20)   // ✅ THIS
            .presentationBackground(Color(.systemBackground)) // ✅ sheet background

        }
        }
    
    
    func statusColors(for status: String) -> (Color, Color, String) {
        switch status {
        case "approved":
            return (Color(hexString: "#e5f7e7"), Color(hexString: "#32b983"), status)
        case "rejected", "inactive":
            return (Color(hexString: "#ffe5e6"), Color(hexString: "#fe0002"), status)
        case "review":
            return (Color(hexString: "#e6eef5"), Color(hexString: "#3e4c63"), "Under review")
        case "sold out":
            return (Color(hexString: "#fff8eb"), Color(hexString: "#ffbb34"), status)
        case "draft":
            return (Color(hexString: "#e6eef5"), Color(hexString: "#3e4c63"), "Draft")
        case "expired":
            return (Color(hexString: "#ffe5e6"), Color(hexString: "#fe0002"), status)
        default:
            return (.clear, .black, status)
        }
    }
}
