//
//  CountryLocationView.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//

import SwiftUI

struct CountryLocationView: View {
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    var navigationController: UINavigationController?
    @State var arrCountries:Array<CountryModel> = []
    @State var isNewPost = false
    var body: some View {
        
            VStack(spacing: 0) {
                HStack{
                    
                    Button {
                        self.navigationController?.popViewController(animated: true)
                    } label: {
                        Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                    }.frame(width: 40,height: 40)
                    
                    Text("Location").font(.custom("Manrope-Bold", size: 20.0))
                        .foregroundColor(.black)
                    Spacer()
                }.frame(height:44).background(Color.white)
                
                // MARK: - Search Bar
                HStack {
                    TextField("Search Country", text: $searchText)
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
                
                // MARK: - Current Location Row
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.orange)
                    
                    Text("Use Current Location")
                        .font(Font.manrope(.medium, size: 15))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    
                }.padding(.top, 8)
                HStack {
                    Button(action: {
                        // Enable location action
                    }) {
                        Text("Enable Location")
                            .font(Font.manrope(.medium, size: 15))
                            .foregroundColor(.black)
                    }.padding(.leading, 20)
                        .padding(.top, 5)
                    Spacer()
                }
                .padding()
                
                Divider()
                
                // MARK: - List of Countries
                ScrollView{
                    ForEach(arrCountries) { country in
                        CountryRow(strTitle:country.name ?? "").frame(height: 40)
                            .onTapGesture{
                                
                                self.navigateToStateListing(country: country)
                            }
                        Divider()
                    }
                }
                
                Spacer()
            }.onAppear{
                fetchCountryListing()
            }
            .navigationTitle("Location")
            .navigationBarBackButtonHidden()
        
    }
    
     func fetchCountryListing(){
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            arrCountries = obj.data?.data ?? []
        }
    }
    
    func navigateToStateListing(country:CountryModel){
       
           let vc = UIHostingController(rootView: StateLocationView(navigationController: self.navigationController, strTitle: country.name ?? "", country: country, isNewPost: self.isNewPost))
           self.navigationController?.pushViewController(vc, animated: true)
           
       
   }
}



struct CountryRow: View {
    var strTitle: String = "India"
    var body: some View {
        HStack {
            Text("\(strTitle)")
                .font(Font.manrope(.medium, size: 15))
            Spacer()
            Image(systemName: "")
                .foregroundColor(.orange)
        }.padding(.leading, 30)
        
    }
}

#Preview {
    CountryRow()
}

