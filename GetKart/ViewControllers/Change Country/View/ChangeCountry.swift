//
//  ChnageCountry.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/07/26.
//

import SwiftUI

struct ChangeCountry: View {
   
    let navigationController:UINavigationController?
    @State private var showCountries:Bool = false
    @State private var selCountries:Countries?
    
    var body: some View {
        
        VStack(alignment: .leading,spacing: 15){
            HeaderView(navigation: navigationController, title: "Settings")
            
            HStack(spacing:10){
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image("globe")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.green)
                        .frame(width: 40, height: 40)
                        .padding(8)
                }
                .frame(width: 40, height: 40)
              
                VStack(alignment:.leading,spacing:3){
                    Text("Where would you like to Buy or Sell?").font(.inter(.medium,size:15))
                    Text("Choose your country/region and currency.").font(.inter(.regular,size:12))
                }
            }.padding(.horizontal)
                            
            HStack{
                VStack(alignment:.leading,spacing: 5){                    Text("Country/Region").foregroundColor(.gray).font(.inter(.regular,size:12))
                    HStack{
                        Text(selCountries?.emoji ?? "").font(.system(size: 30))
                        Text(selCountries?.name ?? "").font(.inter(.medium,size:15))
                    }
                    
                } .padding()
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemGray5).opacity(0.9))
                        .frame(width: 30, height: 30)
                    
                    Image("arrow_right")
                       // .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        //.foregroundColor(.orange)
                        .frame(width: 15, height: 15)
                        .padding()
                }
                .frame(width: 30, height: 30)
                .padding()
                
            }.frame(height:70)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .padding(.horizontal,10)
                .onTapGesture {
                    showCountries = true
                }
            
            HStack{
                
                VStack(alignment:.leading,spacing: 8){
                    Text("Currency").foregroundColor(.gray).font(.inter(.regular,size:12))
                 
                    Text("\(selCountries?.currencySymbol ?? "") - \(selCountries?.currency ?? "") - \(selCountries?.currencyName ?? "")").font(.inter(.medium,size:15)).foregroundColor(.gray)
                    
                    
                } .padding()
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemGray5).opacity(0.9))
                        .frame(width: 30, height: 30)
                    
                    Image("arrow_right")
                       // .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        //.foregroundColor(.orange)
                        .frame(width: 15, height: 15)
                        .padding()
                }
                .frame(width: 30, height: 30)
                .padding()
            }.frame(height:70)
                .background(Color(.systemBackground))
               
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .padding(.horizontal,10)

          
            Button {
             
                if selCountries?.name == Local.shared.countryName{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    
                    updateTImeZone()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        AppDelegate.sharedInstance.restartApp()
                    }
                }
            } label: {
                Text("Done")
                    .font(.inter(.medium, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.orange)
                    .cornerRadius(10)
                
            }.contentShape(Rectangle())
            .padding(.horizontal,10)

            Spacer()
        }
            .background(Color(.systemGroupedBackground))
           
            .sheet(isPresented: $showCountries) {
                CountryListView(onCountrySelected: { country in
                    selCountries = country
                   
                })
                .presentationDetents([.fraction(0.65)])
                .presentationDragIndicator(.hidden)
            }
        
            .onAppear{
                if selCountries == nil{
                    
                    makeCountrySelObject()
                }
            }
    }
    
    func makeCountrySelObject(){
        
        selCountries =  Countries(id: 1, name: Local.shared.countryName, iso3: nil, iso2: nil, numericCode: nil, phoneCode: nil, capital: nil, currency: Local.shared.currency, currencyName: Local.shared.currencyName, currencySymbol: Local.shared.currencySymbol, tld: nil, native: nil, region: nil, regionID: nil, subregion: nil, subregionID: nil, nationality: nil, timezones: nil, latitude: nil, longitude: nil, emoji: Local.shared.emojiCountry, emojiU: nil)
    }
    
    func updateTImeZone(){
        if let timezone = selCountries?.timezones?.first?.zoneName{
            Local.shared.saveTimeZoneHeader(timezone: timezone)
        }
        Local.shared.countryName = selCountries?.name ?? ""
        Local.shared.currency = selCountries?.currency ?? ""
        Local.shared.currencyName = selCountries?.currencyName ?? ""
        Local.shared.currencySymbol = selCountries?.currencySymbol ?? ""
        Local.shared.emojiCountry = selCountries?.emoji ?? ""
    }
}

#Preview {
    ChangeCountry(navigationController: nil)
}
