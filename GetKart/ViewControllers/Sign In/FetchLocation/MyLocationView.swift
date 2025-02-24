//
//  MyLocationView.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//
import SwiftUI

struct MyLocationView: View {
    var navigationController: UINavigationController?
    @StateObject private var locationManager = LocationManager()
    @State private var navigateCountryLocation = false
    var body: some View {
            VStack {
                
                
                HStack{
                    Image("myLocation")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 233, height: 223, alignment: .center)
                }.padding(.top ,30)
                HStack{
                    Text("What's your location")
                        .font(Font.manrope(.semiBold, size: 20.0))
                        .padding(.horizontal)
                        .frame(height: 50, alignment: .center)
                }.padding(.top ,30)
                HStack{
                    Text("Enjoy a personalize selling and buying experience by telling us your locaiton")
                        .font(Font.manrope(.regular, size: 20.0))
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing], 20.0)
                        //.frame(width: UIScreen.main.bounds.size.width - 60,  alignment: .center)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }.padding(.top ,10)
                
                HStack{
                    Button( action: findMyLocationAction){
                        Text("Find My Location")
                            .font(Font.manrope(.regular, size: 15.0))
                            .frame(width: (UIScreen.main.bounds.size.width - 60),height: 50)
                            .padding([.leading,.trailing],10)
                    }.foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(10)
                    
                    
                    
                }.padding(.top ,30)
                HStack{
                    Button( action: otherLocationAction){
                        Text("Other Location")
                            .font(Font.manrope(.regular, size: 15.0))
                            .frame(width: (UIScreen.main.bounds.size.width - 60),height: 50)
                            .padding([.leading,.trailing],10)
                    }.foregroundColor(.orange)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                }.padding(.top ,30)
                
                Spacer()
            }
        
    }
    
    func findMyLocationAction(){
        locationManager.checkLocationAuthorization()
        
        if let coordinate = locationManager.lastKnownLocation {
            print("Latitude: \(coordinate.latitude)")
            
            print("Longitude: \(coordinate.longitude)")
        } else {
            print("Unknown Location")
        }
        
    }
    
    func otherLocationAction(){
        let vc = UIHostingController(rootView: CountryLocationView())
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
}



