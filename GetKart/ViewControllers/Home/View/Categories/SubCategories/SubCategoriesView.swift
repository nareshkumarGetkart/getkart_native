//
//  SubCategoriesView.swift
//  GetKart
//
//  Created by gurmukh singh on 3/7/25.
//

import Foundation
import SwiftUI

struct SubCategoriesView: View {
    
    @State  var subcategories: [Subcategory]?
     var navigationController: UINavigationController?
    @State var isNewPost = false
    @State var isFilter = false
    @State var strTitle = ""
    @State var strCategoryTitle = ""
    @State var category_ids = ""
    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                let title = isNewPost == true ? "Ad Listing" : (strTitle)
                Text("\(title)").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            
            ScrollView{
                HStack {
                    
                    Image("home_dark").renderingMode(.template).foregroundColor(.black)
                        .frame(width: 30, height: 30, alignment: .leading)
                        .padding([.leading],10)
                    Text(strTitle )
                    Spacer()
                    
                }
                
                LazyVStack {
                    ForEach(subcategories ?? []) { objsubCategory in
                        CategoryCellView(subCategory: objsubCategory)
                            .frame(height: 40)
                            .onTapGesture{
                                self.navigateToPostNew(objsubCategory: objsubCategory)
                            }
                        Divider()
                    }
                }
            }
            
        }.navigationBarHidden(true)
    }
                              
     func navigateToPostNew(objsubCategory:Subcategory) {
        if objsubCategory.subcategories?.count == 0 {
            if strCategoryTitle.count == 0 {
                strCategoryTitle = objsubCategory.name ?? ""
                
            }
            let categoryid =  category_ids + ", " + "\(objsubCategory.id ?? 0)"
            if isFilter == true {
                for vc in self.navigationController?.viewControllers ?? []{
                    if vc is FilterVC {
                        
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }else {
                if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                    vc.objSubCategory = objsubCategory
                    vc.strCategoryTitle = strCategoryTitle
                    vc.strSubCategoryTitle = objsubCategory.name ?? ""
                    vc.category_ids = categoryid
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else {
            if strCategoryTitle.count == 0 {
                strCategoryTitle = strTitle + ">" + (objsubCategory.name ?? "")
            }else {
                strCategoryTitle =  ">" + (objsubCategory.name ?? "")
            }
                
            let categoryid =  category_ids + ", " + "\(objsubCategory.id ?? 0)"
            
            let swiftUIView = SubCategoriesView(subcategories: objsubCategory.subcategories, navigationController: self.navigationController, isNewPost: self.isNewPost, isFilter: self.isFilter, strTitle: objsubCategory.name ?? "", strCategoryTitle: strCategoryTitle, category_ids: categoryid) // Create SwiftUI view
            let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
            navigationController?.pushViewController(hostingController, animated: true) //
        }
    }
    
    
}
                
   

struct CategoryCellView: View {
    @State var subCategory:Subcategory?
    var body: some View {
        HStack {
            Text(subCategory?.name ?? "").padding()
            Spacer()
            Image("arrow_right").renderingMode(.template).foregroundColor(.black)
                .padding([.trailing],30)
        }
    }
}
