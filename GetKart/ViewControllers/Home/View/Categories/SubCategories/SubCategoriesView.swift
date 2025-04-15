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
    @State var strTitle = ""
    @State var strCategoryTitle = ""
    @State var  category_id = ""
    @State var category_ids = ""
    
    @State var popType:PopType?
    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                let title = popType == .createPost ? "Ad Listing" : (strTitle)
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
            
            
            if popType == .categoriesSeeAll{
                let vc = UIHostingController(rootView: SearchWithSortView(navigationController:self.navigationController,categroryId: objsubCategory.id ?? 0, categoryName: objsubCategory.name ?? ""))
                self.navigationController?.pushViewController(vc, animated: true)
                
                return
            }
            
            if strCategoryTitle.count == 0 {
                strCategoryTitle = objsubCategory.name ?? ""
                
            }
            category_ids =  category_ids + "," + "\(objsubCategory.id ?? 0)"
            
            
           if popType == .filter {
                for vc in self.navigationController?.viewControllers ?? []{
                    if let vc1 = vc as? FilterVC  {
                        vc1.strCategoryTitle = strCategoryTitle
                        vc1.category_id = self.category_id
                        vc1.category_ids = category_ids
                        vc1.fetchCustomFields()
                        self.navigationController?.popToViewController(vc1, animated: true)
                    }
                }
            }else if popType == .createPost {
                if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                    vc.objSubCategory = objsubCategory
                    vc.strCategoryTitle = strCategoryTitle
                    vc.strSubCategoryTitle = objsubCategory.name ?? ""
                    vc.category_ids = category_ids
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else {
            if strCategoryTitle.count == 0 {
                strCategoryTitle = strTitle + ">" + (objsubCategory.name ?? "")
            }else {
                strCategoryTitle =  ">" + (objsubCategory.name ?? "")
            }
                
            category_ids =  category_ids + ", " + "\(objsubCategory.id ?? 0)"
            
            let swiftUIView = SubCategoriesView(subcategories: objsubCategory.subcategories, navigationController: self.navigationController, strTitle: objsubCategory.name ?? "", strCategoryTitle: strCategoryTitle, category_id:self.category_id, category_ids: category_ids, popType: self.popType) // Create SwiftUI view
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
            Image("arrow_right").renderingMode(.template).foregroundColor(.black).background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            //.padding(.leading, 8)
               .padding([.trailing],30)
        }
        .contentShape(Rectangle())
    }
}
