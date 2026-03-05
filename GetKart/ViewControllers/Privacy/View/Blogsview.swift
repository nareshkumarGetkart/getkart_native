//
//  Blogsview.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/03/25.
//

import SwiftUI
/*
struct Blogsview: View {
    var title:String = ""
    @State var blogsArray = [BlogsModel]()
    var navigationController:UINavigationController?
    @State private var isDataLoading = false
    @State private var page = 1

    var body: some View {
        HStack{
            
            Button {
                
                navigationController?.popViewController(animated: true)

            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text(title).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
        }.frame(height:44).background(Color(UIColor.systemBackground))
        
     
        ScrollView{
           VStack(spacing:0){
                ForEach(blogsArray) { blog in
                    BlogCell(obj:blog)
                        .onAppear{
                            
                            if let lastItem = blogsArray.last, lastItem.id == blog.id, !isDataLoading {
                                blogslistApi()
                            }
                        }
                        .onTapGesture {
                            
                            let hostingController = UIHostingController(rootView: BlogDetailView(title: "Blogs",obj:blog,navigationController:self.navigationController)) // Wrap in UIHostingController
                            hostingController.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(hostingController, animated: true)
                            
                        }
                }
               // Spacer()
            }.onAppear()
            {
                if blogsArray.count == 0{
                    blogslistApi()
                }
            }
        }.background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
    }
    
    func blogslistApi(){
        self.isDataLoading = true

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader:true , url: Constant.shared.blogs + "?page=\(page)") { (obj:Blogs) in
           
            if obj.code == 200{
                
                if self.page == 1{
                    self.blogsArray.removeAll()
                }
                
                if obj.data != nil {
                    
                    self.blogsArray.append(contentsOf: obj.data?.data ?? [])
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        self.page += 1
                        self.isDataLoading = false
                    })
                }
            }else{
                self.isDataLoading = false

            }
        }
        
    }
}

#Preview {
    Blogsview()
}



struct BlogCell:View{
    
    let obj:BlogsModel
    
    var body: some View {
        
        VStack(alignment: .leading){
            
           // HStack{ Spacer()}.frame(height: 10)
            AsyncImage(url: URL(string: obj.image ?? "")) { image in
                image.resizable()//.aspectRatio(contentMode: .)
                    .frame(width:  UIScreen.main.bounds.width-20, height: 150).clipped()
                
            }placeholder: {
                
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fill)
                    .frame(width:  UIScreen.main.bounds.width-20, height: 150).clipped()
                
            }
            Text(obj.title ?? "")
                .font(.manrope(.medium, size: 18)).padding([.leading,.trailing])
                .foregroundColor(Color(UIColor.label))
                .padding(.top,10)
            
         /*   if let nsAttributedString = try? NSAttributedString(data: Data((obj.description ?? "").utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil),
              
                
                let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
                Text(attributedString).font(.manrope(.regular, size: 16)).lineLimit(3).padding([.leading,.trailing,.top],8).padding(.bottom)
                    .foregroundColor(Color(UIColor.label))
            } else {
                Text(obj.description ?? "").font(.manrope(.regular, size: 16)).lineLimit(3).padding([.leading,.trailing,.top],8).padding(.bottom)
                    .foregroundColor(Color(UIColor.label))
            }
            */
            Group {
                if let attributedString = cleanedAttributedString {
                    Text(attributedString)
                        .font(.manrope(.regular, size: 16))
                        .lineLimit(3)
                        .padding([.leading, .trailing, .top], 8)
                        .padding(.bottom)
                        .foregroundColor(Color(UIColor.label)) // Adapts to dark/light mode
                } else {
                    Text(obj.description ?? "")
                        .font(.manrope(.regular, size: 16))
                        .lineLimit(3)
                        .padding([.leading, .trailing, .top], 8)
                        .padding(.bottom)
                        .foregroundColor(Color(UIColor.label))
                }
            }
 
        }
           
            .background(Color(UIColor.systemBackground)).cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(10)
        
    }
    
    var cleanedAttributedString: AttributedString? {
        guard let data = (obj.description ?? "").data(using: .utf8),
              let nsAttributedString = try? NSMutableAttributedString(
                  data: data,
                  options: [.documentType: NSAttributedString.DocumentType.html],
                  documentAttributes: nil
              ) else {
            return nil
        }

        // Remove all foregroundColor attributes to support dark mode
        nsAttributedString.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: nsAttributedString.length)) { _, range, _ in
            nsAttributedString.removeAttribute(.foregroundColor, range: range)
        }

        return try? AttributedString(nsAttributedString, including: \.uiKit)
    }

}


*/

#Preview {
    Blogsview()
}


import SwiftUI

struct Blogsview: View {

    var title: String = ""
    var navigationController: UINavigationController?

    @State private var blogsArray: [BlogsModel] = []
    @State private var isDataLoading = false
    @State private var page = 1
    @State private var hasMoreData = true

    var body: some View {

        VStack(spacing: 0) {

            // Header
            HStack {
                Button {
                    navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }
                .frame(width: 40, height: 40)

                Text(title)
                    .font(.custom("Manrope-Bold", size: 20))
                    .foregroundColor(Color(UIColor.label))

                Spacer()
            }
            .frame(height: 44)
            .background(Color(UIColor.systemBackground))

            // Content
            ScrollView {
                LazyVStack(spacing: 0) {

                    ForEach(blogsArray) { blog in
                        BlogCell(obj: blog)
                            .onTapGesture {
                                if let nav = navigationController {
                                    let hosting = UIHostingController(
                                        rootView: BlogDetailView(
                                            title: "Blogs",
                                            obj: blog,
                                            navigationController: nav
                                        )
                                    )
                                    hosting.hidesBottomBarWhenPushed = true
                                    nav.pushViewController(hosting, animated: true)
                                }
                            }
                    }

                    // Loading Indicator
                    if isDataLoading {
                        ProgressView()
                            .padding()
                    }

                    // Pagination Trigger (SAFE)
                    if hasMoreData {
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                loadMoreIfNeeded()
                            }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .onAppear {
            if blogsArray.isEmpty {
                blogslistApi()
            }
        }
    }

    // MARK: - Pagination Control

    private func loadMoreIfNeeded() {
        guard !isDataLoading else { return }
        guard hasMoreData else { return }
        guard !blogsArray.isEmpty else { return }

        blogslistApi()
    }

    // MARK: - API Call

    private func blogslistApi() {

        guard !isDataLoading else { return }

        isDataLoading = true

        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: true,
            url: Constant.shared.blogs + "?page=\(page)"
        ) { (obj: Blogs) in

            DispatchQueue.main.async {

                defer { self.isDataLoading = false }

                guard obj.code == 200 else { return }

                let newItems = obj.data?.data ?? []

                if self.page == 1 {
                    self.blogsArray.removeAll()
                }

                if newItems.isEmpty {
                    self.hasMoreData = false
                } else {
                    self.blogsArray.append(contentsOf: newItems)
                    self.page += 1
                }
            }
        }
    }
}

struct BlogCell: View {

    let obj: BlogsModel

    var body: some View {

        VStack(alignment: .leading) {

            AsyncImage(url: URL(string: obj.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } placeholder: {
                Image("getkartplaceholder")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }

            Text(obj.title ?? "")
                .font(.custom("Manrope-Medium", size: 18))
                .foregroundColor(Color(UIColor.label))
                .padding(.horizontal)
                .padding(.top, 10)

            if let attributed = obj.parsedDescription {
                Text(attributed)
                    .font(.custom("Manrope-Regular", size: 16))
                    .lineLimit(3)
                    .foregroundColor(Color(UIColor.label))
                    .padding([.horizontal, .top], 8)
                    .padding(.bottom)
            } else {
                Text(obj.description ?? "")
                    .font(.custom("Manrope-Regular", size: 16))
                    .lineLimit(3)
                    .foregroundColor(Color(UIColor.label))
                    .padding([.horizontal, .top], 8)
                    .padding(.bottom)
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(10)
    }
}


extension BlogsModel {

    var parsedDescription: AttributedString? {

        guard let description = description,
              let data = description.data(using: .utf8),
              let nsAttributedString = try? NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
              )
        else { return nil }

        nsAttributedString.removeAttribute(
            .foregroundColor,
            range: NSRange(location: 0, length: nsAttributedString.length)
        )

        return try? AttributedString(nsAttributedString, including: \.uiKit)
    }
}
