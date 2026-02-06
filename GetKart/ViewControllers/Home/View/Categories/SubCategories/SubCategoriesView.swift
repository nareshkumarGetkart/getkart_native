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
    @State var category_id = ""
    @State var category_ids = ""
    @State var popType:PopType?
    @State var screenNumber = 1
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack(spacing:0){
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                let title = popType == .createPost ? "Ad Listing" : (strTitle)
                Text("\(title)").font(Font.inter(.semiBold, size: 18.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
                .onAppear{
                    if screenNumber == 1{
                        category_ids = category_id
                        strCategoryTitle = strTitle
                        
                    }
                }
            
            ScrollView{
                HStack {
                    
                    Image("home_dark").renderingMode(.template).foregroundColor(Color(UIColor.label))
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

            
            if popType == .filter{
                if strCategoryTitle.count == 0 {
                    strCategoryTitle = objsubCategory.name ?? ""
                }else{
                    strCategoryTitle = strCategoryTitle + ">\(objsubCategory.name ?? "")"
                }
                
            }else{
                
                if strCategoryTitle.count == 0 {
                    strCategoryTitle = objsubCategory.name ?? ""
                }
            }
             category_ids =  category_ids + "," + "\(objsubCategory.id ?? 0)"
            
            
            if popType == .categoriesSeeAll{
                let vc = UIHostingController(rootView: SearchWithSortView(categroryId: objsubCategory.id ?? 0, navigationController:self.navigationController, categoryName: objsubCategory.name ?? "", categoryIds: category_ids, categoryImg: objsubCategory.image ?? ""))
                self.navigationController?.pushViewController(vc, animated: true)
                
                return
            }
            
           if popType == .filter {
               
               
                for vc in self.navigationController?.viewControllers ?? []{
                    if let vc1 = vc as? FilterVC  {
                        vc1.strCategoryTitle = strCategoryTitle
                        vc1.category_id = self.category_id
                        
                        let catArr = category_ids.components(separatedBy: ",")
                        if (catArr.count) > 1 {
                            if let subCatId = catArr.last{
                                vc1.category_id = subCatId
                            }
                        }
                        vc1.category_ids = category_ids
                        vc1.fetchCustomFields()
                        self.navigationController?.popToViewController(vc1, animated: true)
                    }
                }
            }else if popType == .createPost {
                
             
                let idsArray = category_ids
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }

                // Remove duplicates while keeping order
                var seen = Set<String>()
                let uniqueArray = idsArray.filter { seen.insert($0).inserted }

                // Join back to string
                category_ids = uniqueArray.joined(separator: ",")

                if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                    vc.objSubCategory = objsubCategory
                    vc.strCategoryTitle = strCategoryTitle
                    vc.strSubCategoryTitle = objsubCategory.name ?? ""
                    vc.category_ids = category_ids
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
               /*
                let swiftuIview = CreateAdFirstView(navigationController: self.navigationController,objSubCategory:objsubCategory, strCategoryTitle:strCategoryTitle,strSubCategoryTitle:objsubCategory.name ?? "", category_ids:category_ids)
                
                let hostingVC = UIHostingController(rootView: swiftuIview)
                
                self.navigationController?.pushViewController(hostingVC, animated: true)
                */
                
            }
        }else {
            
            if strCategoryTitle.count == 0 {
                strCategoryTitle = strTitle + ">" + (objsubCategory.name ?? "")
            }else {
                strCategoryTitle +=  ">" + (objsubCategory.name ?? "")
            }
                
            category_ids =  category_ids + "," + "\(objsubCategory.id ?? 0)"
            
       

            let swiftUIView = SubCategoriesView(subcategories: objsubCategory.subcategories, navigationController: self.navigationController, strTitle: objsubCategory.name ?? "", strCategoryTitle: strCategoryTitle, category_id:self.category_id, category_ids: category_ids, popType: self.popType,screenNumber: screenNumber + 1) // Create SwiftUI view
            let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
            navigationController?.pushViewController(hostingController, animated: true) //
        }
    }
    
    
}
                
   

struct CategoryCellView: View {
     let subCategory:Subcategory?
    var body: some View {
        HStack {
            if let imgUrl = subCategory?.image{
                
                AsyncImage(url: URL(string: imgUrl)) { img in
                    
                    img.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40)
                        .cornerRadius(20.0)
                        .clipped()
                } placeholder: {
                    Image("getkartplaceholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background(Color(hex: "#FEF6E9"))
                            .frame(width: 40,height: 40)
                            .cornerRadius(20.0)
                            .clipped()
                }

            }
            Text(subCategory?.name ?? "").font(.inter(.regular, size: 15.0))
                .foregroundColor(.primary)
                .padding()
            Spacer()
            Image("arrow_right")
                .renderingMode(.template)
                .foregroundColor(Color(UIColor.label))
                .padding(8)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
        .contentShape(Rectangle())
    }
}
