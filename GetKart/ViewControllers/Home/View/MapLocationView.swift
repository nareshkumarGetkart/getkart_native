//
//  MapLocationView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/04/25.
//

import SwiftUI

struct MapLocationView: View {
    
    let latitude: Double
    let longitude: Double
    let address: String
    var navController:UINavigationController?
    
    var body: some View {
        
        VStack{
            ZStack{
                MapView(latitude: latitude, longitude: longitude,address:address)
                   .ignoresSafeArea()
                
                VStack{
                    HStack{
                        Button {
                            navController?.popViewController(animated: true)
                        } label: {
                            Image("arrow_left").renderingMode(.template)
                                .foregroundColor(Color(UIColor.label))
                                .contentShape(Rectangle()).frame(width:44, height: 44)
                                .background(Color.white.opacity(0.001))
                            
                        }.frame(width:44, height: 44).padding(.leading,10)
                        
                        Spacer()
                        
                    }.frame(height: 44)
                    
                    Spacer()

                }
            }
        }.navigationBarHidden(true)
    }
}

#Preview {
    MapLocationView(latitude:0.0, longitude: 0.0, address: "", navController: nil)
}
