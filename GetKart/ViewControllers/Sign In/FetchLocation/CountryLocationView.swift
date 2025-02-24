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
    var body: some View {
        
            VStack(spacing: 0) {
                HStack{
                    
                    Button {
                        AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
                    } label: {
                        Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                    }.frame(width: 40,height: 40)
                    
                    Text("Location").font(.custom("Manrope-Bold", size: 20.0))
                        .foregroundColor(.black)
                    Spacer()
                }.frame(height:60).background(Color.white)
                
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
                List {
                    NavigationLink(destination: Text("All Countries")) {
                        Text("All Countries")
                    }
                    NavigationLink(destination: Text("India")) {
                        Text("India")
                    }
                    NavigationLink(destination: Text("United States")) {
                        Text("United States")
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Location")
            .navigationBarBackButtonHidden()
        
    }
}


