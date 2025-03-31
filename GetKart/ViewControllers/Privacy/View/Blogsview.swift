//
//  Blogsview.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/03/25.
//

import SwiftUI

struct Blogsview: View {
    var title:String = ""
    @State var blogsArray = [BlogsModel]()
    var navigationController:UINavigationController?
    
    var body: some View {
        HStack{
            
            Button {
                
                navigationController?.popViewController(animated: true)

            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text(title).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background()
        
     
        ScrollView{
            VStack(spacing:0){
                HStack{Spacer()}

                ForEach(blogsArray) { blog in
                    BlogCell(obj:blog)
                        .onTapGesture {
                            
                            let hostingController = UIHostingController(rootView: BlogDetailView(title: "Blogs",obj:blog,navigationController:self.navigationController)) // Wrap in UIHostingController
                            hostingController.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(hostingController, animated: true)
                            
                        }
                }
                Spacer()
            }.onAppear()
            {
                if blogsArray.count == 0{
                    blogslistApi()
                }
            }
        }.background(Color(UIColor.systemGroupedBackground)).navigationBarHidden(true)
    }
    
    func blogslistApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader:true , url: Constant.shared.blogs) { (obj:Blogs) in
            if obj.data != nil {
                self.blogsArray.append(contentsOf: obj.data?.data ?? [])
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
            
            HStack{ Spacer()}.frame(height: 10)
            AsyncImage(url: URL(string: obj.image ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
                    .frame(width:  UIScreen.main.bounds.width-20, height: 150)
                
            }placeholder: {
                
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fill)
                    .frame(width:  UIScreen.main.bounds.width-20, height: 150)
                //                ProgressView().progressViewStyle(.circular)
                
            }
            Text(obj.title ?? "").font(.manrope(.medium, size: 18)).padding([.leading,.trailing]).padding(.top,10)
            
            if let nsAttributedString = try? NSAttributedString(data: Data((obj.description ?? "").utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil),
               let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
                Text(attributedString).font(.manrope(.regular, size: 16)).lineLimit(3).padding([.leading,.trailing,.top],8).padding(.bottom)
            } else {
                Text(obj.description ?? "").font(.manrope(.regular, size: 16)).lineLimit(3).padding([.leading,.trailing,.top],8).padding(.bottom)
            }
            
        }
           
            .background(Color.white).cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(10)
        
    }
}



