//
//  StateLocationView.swift
//  GetKart
//
//  Created by gurmukh singh on 3/4/25.
//

import Foundation
import SwiftUI

struct StateLocationView: View {
    var navigationController: UINavigationController?
    @State var arrStates:Array<StateModal> = []
    var strTitle:String = ""
    @State private var searchText = ""
    @State var pageNo = 1
    @State var totalRecords = 1
    var country:CountryModel = CountryModel()
    @State var isNewPost = false
    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                
                Text("\(strTitle)").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            
            // MARK: - Search Bar
            HStack {
                TextField("Search State", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 8)
                    .frame(height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                // Icon button on the right (for settings or any other action)
                Button(action: {
                    // Action for icon button
                    
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            
            
            
            
            Divider()
            
            // MARK: - List of Countries
            ScrollView{
                
                //ForEach(0..<arrStates.count){ index in
                //let state = arrStates[index]
                LazyVStack {
                    ForEach(arrStates, id:\.id) { state in
                        
                        CountryRow(strTitle:state.name ?? "").frame(height: 40)
                        
                            .onAppear{
                                if  let index = arrStates.firstIndex(where: { $0.id == state.id }) {
                                    if index == arrStates.count - 1{
                                        if self.totalRecords != arrStates.count {
                                            fetchStateListing()
                                        }
                                    }
                                }
                                
                            }
                            .onTapGesture{
                                self.NavigateToCityListing(state:state)
                            }
                        Divider()
                    }
                }.gesture(
                    DragGesture().onChanged { value in
                        if value.translation.height > 0 {
                            print("Scroll down")
                        } else {
                            print("Scroll up")
                        }
                    }
                )
            }
            Spacer()
        }.onAppear{
            self.fetchStateListing()
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
    
}
    
    func fetchStateListing(){
        let url = Constant.shared.get_States + "?country_id=\(country.id ?? 0)&page=\(pageNo)"
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) { (obj:StateParse) in
           self.totalRecords = obj.data?.total ?? 0
           self.pageNo = pageNo + 1
           self.arrStates.append(contentsOf: obj.data?.data ?? [])
           print(arrStates)
       }
   }
    
    func NavigateToCityListing(state:StateModal){
        
        let vc = UIHostingController(rootView: CityLocationView(navigationController: self.navigationController,country: country, state: state, isNewPost: self.isNewPost))
           self.navigationController?.pushViewController(vc, animated: true)
           
       
   }
}


#Preview {
    StateLocationView()
}
