//
//  SubCategoriesView.swift
//  GetKart
//
//  Created by gurmukh singh on 3/7/25.
//

import Foundation
import SwiftUI

struct SubCategoriesView: View {
    @State var subcategories: [Subcategory]?
    
    var navigationController: UINavigationController?
    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                
                Text("").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            
            ScrollView{
                LazyVStack {
//                    ForEach(subcategories) { objsubCategory in
//                        CategoryCellView(subCategory: objsubCategory)
//                    }
                }
            }
            
        }
    }
}
                
    #Preview {
        SubCategoriesView(subcategories: [])
    }

struct CategoryCellView: View {
    @State var subCategory:Subcategory?
    var body: some View {
        HStack {
            Image("arrow_left").renderingMode(.template).foregroundColor(.black)
        }
    }
}
