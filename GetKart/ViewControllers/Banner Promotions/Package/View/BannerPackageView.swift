//
//  BannerPackageView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 13/07/26.
//

import SwiftUI

struct BannerPackageView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var planListArray:Array<PlanModel>?
    var packageSelectedPressed: ((_ selPkgObj: PlanModel, _ selPaymentMethod: SelPaymentMethod) -> Void)?
    @State private var currentStep: BoostStep = .selectPlan
    @State private var selectedPlan: PlanModel?
    @State private var selectedPayment: SelPaymentMethod = .wallet
    
    @StateObject private var walletVM = MyWalletViewModel()
    @State private var showInsufficientBalanceAlert = false
    @State private var alertMessage = ""
    
    init( packageSelectedPressed: ((_ selPkgObj: PlanModel, _ selPaymentMethod: SelPaymentMethod) -> Void)? = nil
    ) {

        self.packageSelectedPressed = packageSelectedPressed

    }
    var body: some View {
        VStack(spacing: 16) {
            VStack{
                HStack {
                    Spacer()
                        Text("Promotion Pakages")
                            .font(.inter(.semiBold, size: 18))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark").renderingMode(.template)
                            .foregroundColor(Color(.label))
                            .padding(8)
                    }
                }.padding(.horizontal)
                
                Divider()
                
                StepIndicatorView(step: currentStep)
            }
            
            if currentStep == .selectPlan {
                Text("Want more product views? Banner Ads bring users straight to you.").font(.inter(.regular,size:12))
                    .foregroundColor(.gray)
                
                planSelectionView
                
            } else {
                
                paymentView
            }

   
        }
        .padding(.top, 10)
        .background(Color(.systemBackground))
     
        .onAppear {
            if (planListArray ?? []).isEmpty{
                getPackagesApi()
            }
        }
        .alert("Insufficient Wallet Balance",
               isPresented: $showInsufficientBalanceAlert) {

          
            Button("Ok", role: .cancel) { }

//            Button("Add Money") {
//
//                // Navigate to Add Money screen
//
//            }

        } message: {

            Text(alertMessage)
        }
    }

   
    private var planSelectionView: some View {

        VStack(spacing: 0) {
        

            ScrollView(showsIndicators: false) {

                LazyVStack(spacing: 15) {

                    ForEach(planListArray ?? [], id:\.id) { plan in
                        BannerPackageCell(
                            obj: plan,
                            isSelected: selectedPlan?.id == plan.id
                        )
                        .onTapGesture {

                            withAnimation {

                                selectedPlan = plan
                            }
                        }
                    }

                    Button {

                        guard selectedPlan != nil else {

                            return
                        }

                        withAnimation {

                            currentStep = .payment
                        }

                    } label: {

                        HStack {

                            Spacer()

                            Text("Continue to Payment")
                                .font(.inter(.semiBold, size: 18))

                            Image(systemName: "arrow.right")

                            Spacer()
                        }
                        .foregroundColor(.white)
                        .frame(height: 54)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .padding(.top,5)

                    Button {
                        dismiss()

                       // if let url = URL(string: Constant.shared.BOARDBOOST_DEMO){
                            let vc = UIHostingController(rootView:  PreviewURL(fileURLString:Constant.shared.BANNER_DEMO))
                            AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)

                        //}
                    } label: {

                        Text("How It Benefits You")
                            .underline()
                            .font(.inter(.medium, size: 15))
                            .foregroundColor(Color(hex:"#192E73"))
                    }
                    .padding(.bottom,25)

                }
                .padding([.horizontal])
            }
        }
    }
    
    private var paymentView: some View {

        ScrollView(showsIndicators: false) {

            VStack(spacing: 10) {

                if let plan = selectedPlan {

                    SelectedPlanCellCard(planObj: plan)
                }

                Text("Select payment method")
                    .font(.inter(.medium, size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
        
                WalletPaymentCard(
                    isSelected: selectedPayment == .wallet,
                    plan: selectedPlan,
                    walletBalance: Double(walletVM.walletObj?.balance ?? 0) 
                )
                .onTapGesture {
                    selectedPayment = .wallet
                }

                
                OtherPaymentCard(
                    isSelected: selectedPayment == .other
                )
                .onTapGesture {
                    selectedPayment = .other
                }

                VStack(spacing:0){
                    Divider().padding([.top],8)
                    TotalAmountView(plan: selectedPlan)
                }

                Button {
                    if let selPlan = selectedPlan{
                        if selectedPayment == .wallet {
                            
                            let planAmount = Double(selPlan.finalPrice ?? "0") ?? 0
                            let walletBalance = Double(walletVM.walletObj?.balance ?? 0)
                            
                            if walletBalance < planAmount {
                                
                                alertMessage = "Your wallet balance is insufficient to purchase this plan. Please add \(Local.shared.currencySymbol)\(Int(planAmount-walletBalance)) to your wallet and try again."
                                
                              
                                showInsufficientBalanceAlert = true
                                return
                            }
                        }
                        dismiss()
                        packageSelectedPressed?(selPlan,selectedPayment)
                    }

                } label: {

                    HStack {

                        Image(systemName: "lock")

                        Text("Pay \(Local.shared.currencySymbol)\(selectedPlan?.finalPrice ?? "0") & Promote Now")
                            .font(.inter(.semiBold, size: 18))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(12)
                }

                Button {
                    dismiss()

                    //if let url = URL(string: Constant.shared.BOARDBOOST_DEMO){
                        let vc = UIHostingController(rootView:  PreviewURL(fileURLString:Constant.shared.BANNER_DEMO))
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)

                   // }
                } label: {

                    Text("How It Benefits You").font(.inter(.medium, size: 14))
                        .underline()
                        .foregroundColor(Color(hex:"#192E73"))
                }.padding(.bottom,5)

            }
            .padding([.horizontal])
        }
    }
    
    
    
    
    func getPackagesApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_campaign_package ) { (obj:PromotionPkg) in
            
            if obj.code == 200 {
                planListArray = obj.data
            }
        }
    }
}


struct SelectedPlanCellCard: View {

    let planObj: PlanModel

    var body: some View {

        BannerPackageCell(
            obj: planObj,
            isSelected: false
        )
    }
}

struct BannerPackageCell:View {
    
    let obj:PlanModel
    let isSelected: Bool
    
    var body: some View {
        
        HStack{
            Text(obj.name ?? "").font(.manrope(.medium, size: 16)).padding(.leading)
            Spacer()
            if (obj.discountInPercentage ?? "0") != "0"{
                
                Text(" \(obj.discountInPercentage ?? "0")% Savings ").frame(height:20).font(.manrope(.medium, size: 13)).background(Color(hexString: "#FF9900"))
                
                
                let originalPrice = "\(obj.price ?? "0")".formatNumberWithComma()
                
                Text("\(Local.shared.currencySymbol)\(originalPrice)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .strikethrough(true, color: .gray)
                
                let amt = "\(obj.finalPrice ?? "0")".formatNumberWithComma()
                Text("\(Local.shared.currencySymbol)\(amt)").font(.manrope(.regular, size: 16)).padding(.trailing)
            }else{
                let amt = "\(obj.price ?? "0")".formatNumberWithComma()
                Text("\(Local.shared.currencySymbol)\(amt)").font(.manrope(.regular, size: 16)).padding(.trailing)
            }
            
            
        }.frame(height:55)
            .background(
                
                isSelected
                ? Color.orange.opacity(0.05)
                : Color(.systemBackground)
            )
            .overlay(
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.orange : Color.gray.opacity(0.35),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        
    }
}



