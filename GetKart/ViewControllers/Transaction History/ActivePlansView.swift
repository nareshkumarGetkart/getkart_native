//
//  ActivePlansView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/01/26.
//

import SwiftUI

struct ActivePlansView: View {
    
    var  navigation:UINavigationController?

    var body: some View {
        
        ScrollView{
            LazyVStack(spacing:8){
                
                ForEach(0..<5, id:\.self){index in
                    ActivePlansCell()
                }
                
                Spacer()
            }.padding(5).padding(.top)
        }.background(Color(.systemGray6))

    }
}

#Preview {
    ActivePlansView(navigation:nil)
}





struct ActivePlansCell:  View {
    var body: some View {
        VStack(alignment:.leading,spacing:2){
            
            VStack(alignment:.leading){
                Text("Order ID: #3453534543")
                Text("Banner Promotion")
                Text("Package availability")
            }.padding(.horizontal).padding(.vertical,5).padding(.top)
            
            HStack{
                Spacer()

                VStack{
                    Text("Purchased")
                    Text("1000")
                }.padding(.vertical,5)
                Spacer()

                Divider().frame(height:30)
                Spacer()

                VStack{
                    Text("Remaining")
                    Text("35 clciks")
                }.padding(.vertical,5)
                Spacer()

                Divider().frame(height:30)
                Spacer()
                VStack{
                    Text("Current")
                    Text("65 clicks")
                }.padding(.vertical,5)
                Spacer()


            }.background(Color(.systemOrange).opacity(0.2)).padding(.horizontal).padding(.vertical,5)
            
            VStack{
                HStack{
                    Text("Purchased on")
                    Spacer()
                    Text("Sep 10, 2025 at 08:25 PM")
                }
                
                HStack{
                    Text("Expiring on")
                    Spacer()
                    Text("Sep 10, 2025 at 08:25 PM")
                }
            }.padding(.horizontal).padding(.vertical,5).padding(.bottom)
            
        }.background(Color(.systemBackground)).padding(.horizontal,5).cornerRadius(8.0)
    }
}
