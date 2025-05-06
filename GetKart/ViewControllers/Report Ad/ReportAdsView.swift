//
//  ReportAdsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 07/03/25.
//

import SwiftUI

struct ReportAdsView: View {
   
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedReason: String? = nil
    @State private var listArray = [ReportModel]()
    @State private var selectedReasonId: Int? = nil
    var itemId = 0

    var onReportSubmit: (Bool) -> Void  // Callback for offer submission

    var body: some View {
        
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Report item").font(.manrope(.semiBold, size: 20))
                    .font(.title2)
                    .bold()
                    .padding([.top, .bottom], 15)
                
                ForEach(listArray) { report in
                    
                    let selReason = report.reason ?? ""
                    let selReasonId = report.id ?? 0


                    Button(action: {
                        selectedReason = selReason
                        selectedReasonId = selReasonId
                    }) {
                        
                        Text(selReason).font(.manrope(.medium, size: 17))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedReason == selReason ? Color.orange.opacity(0.2) : Color(UIColor.systemGray6))
                            .foregroundColor(selectedReason == selReason ? .orange : .black)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedReason == selReason ? Color.orange : Color.clear, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }.font(.manrope(.semiBold, size: 15)).foregroundColor(.black)
                        .frame(maxWidth: .infinity,minHeight: 40,maxHeight: 40)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(20).padding(5)
                    
                    Button("Ok") {
                        // Handle report submission
                        if let selId = selectedReasonId{
                            
                            self.reportItemApi(reportedReasonId: selId)
                        }
                    }.font(.manrope(.semiBold, size: 15))
                    .frame(maxWidth: .infinity,minHeight: 40,maxHeight:40)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(5)
                }.padding(.vertical)
                .padding(.horizontal)
                .padding(.bottom, 1)
            } .edgesIgnoringSafeArea(.all)
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
        }.onAppear{
            if listArray.count == 0{
                getReportListApi()
            }
        }
    }
    
    
    func getReportListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_report_reasons) { (obj:Report) in
            
            if obj.data != nil {
                self.listArray = obj.data?.data ?? []
            }
            
        }
    }
    
    
    
    func reportItemApi(reportedReasonId:Int){
        
        let params = ["report_reason_id":reportedReasonId,"item_id":itemId] as [String : Any]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.add_reports, param: params,methodType: .post) {  responseObject, error in
            
            
            if(error != nil)
            {
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    AlertView.sharedManager.showToast(message: message)
                   presentationMode.wrappedValue.dismiss()
                    onReportSubmit(true) // Pass the offer back
                }
            }
        }
    }
}

//
//#Preview {
//    ReportAdsView(, onReportSubmit: {
//        
//    })
//}



