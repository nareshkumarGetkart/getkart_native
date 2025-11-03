//
//  PreviewAdView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI

struct PreviewAdView: View {
    var navigationController:UINavigationController?
    var image:UIImage
    private let titleArray = ["Home Page","Buy Packages","Item description","All categories"]
    private let iconArray = ["home","buyPackages","category","category"]

    var body: some View {
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Preview ad").font(.manrope(.bold, size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            
         }.frame(height:44).background(Color(UIColor.systemBackground))
        
        
        VStack(spacing:15){
            HStack{
                GeometryReader { geo in
                    
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height).cornerRadius(8.0)
                        .clipped()
                }
            }.frame(height: 140)
            Text("Your ad will run in these placements.")
            Divider()
            
            VStack{
                ForEach(titleArray.indices, id: \.self) { index in
                    
                    PreviewAdsCell(title: titleArray[index], icon: iconArray[index]).onTapGesture {
                        pushtoPreviewScren(index: index)
                    }
                }
            }
            
            Spacer()
        }.padding().background(Color(.systemGray6))
    }
    
    
    func pushtoPreviewScren(index:Int){
        if index == 0{
            if  let destvC = StoryBoard.postAdd.instantiateViewController(withIdentifier: "AdsPreviewBannerImageVC") as? AdsPreviewBannerImageVC{
                destvC.image = image
                self.navigationController?.pushViewController(destvC, animated: true)
            }
        }else if index == 1{
            if  let destvC = StoryBoard.postAdd.instantiateViewController(withIdentifier: "AdsPreviewImageBuyPckgVC") as? AdsPreviewImageBuyPckgVC{
                destvC.image = image
                self.navigationController?.pushViewController(destvC, animated: true)
            }
        }else if index == 2{
            if  let destvC = StoryBoard.postAdd.instantiateViewController(withIdentifier: "AdsPreviewBannerImageItemVC") as? AdsPreviewBannerImageItemVC{
                destvC.image = image
                self.navigationController?.pushViewController(destvC, animated: true)
            }
        }else if index == 3{
            if  let destvC = StoryBoard.postAdd.instantiateViewController(withIdentifier: "AdsPreviewImageCategoriesVC") as? AdsPreviewImageCategoriesVC{
                destvC.image = image
                self.navigationController?.pushViewController(destvC, animated: true)
            }
        }
    }

}

#Preview {
    PreviewAdView(navigationController:nil,image: UIImage(imageLiteralResourceName: "getkartplaceholder"))
}



struct PreviewAdsCell:View {
    
    let title:String
    let icon:String

    var body: some View {
        HStack{
            ZStack{
                RoundedRectangle(cornerRadius: 10)  // Square with rounded corners
                    .fill(Color.yellow.opacity(0.1))
                    .frame(width: 50, height: 50) // Background size
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(icon).renderingMode(.template)
                    .foregroundColor(.orange)
            }.padding(.leading)
            
            Text(title).font(.manrope(.medium, size: 15.0)).foregroundColor(Color(.label))

            
            Spacer()
            
            
            ZStack{
                RoundedRectangle(cornerRadius: 10) // Square with rounded corners
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40) // Background size
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image("arrow_right").renderingMode(.template)
                    .foregroundColor(.black)
            }.padding(.trailing)
            
            
        }.frame(height:60)
            .background(
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
            
        )
        
        .overlay {
            RoundedRectangle(cornerRadius: 8.0).stroke(Color(hexString: "#DADADA"), lineWidth: 1.0)
        }
    }
}
