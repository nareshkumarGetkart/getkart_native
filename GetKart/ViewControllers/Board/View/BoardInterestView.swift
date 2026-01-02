//
//  BoardInterestView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/12/25.
//

import SwiftUI
import Kingfisher

struct BoardInterestView: View {
    var navigationController:UINavigationController?
    @StateObject private var objViewModel:CategoryViewModel = CategoryViewModel(type: 2)
    @State private var isChanged:Bool = false
    
    var body: some View {
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                if isChanged{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshInterestChangeBoardScreen.rawValue), object: nil, userInfo: nil)
                }
            } label: {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
            }
            
            Text("Add Your Interests") .font(.inter(.medium, size: 18))
            Spacer()
            
        }.padding().frame(height:44)
        
        ScrollView{
            
            let columns = [
                GridItem(.adaptive(minimum: widthScreen/3.0-10, maximum: widthScreen/3.0-10)),
                GridItem(.adaptive(minimum: widthScreen/3.0-10, maximum: widthScreen/3.0-10)),
                GridItem(.adaptive(minimum: widthScreen/3.0-10, maximum: widthScreen/3.0-10)),
            ]
            
            
            
            LazyVGrid(columns: columns, alignment:.leading, spacing: 10) {
                
                
                ForEach(objViewModel.listArray ?? [], id: \.id) { catObj in
                    BoardCategoryCell(obj: catObj) { updatedObj in

                        if let index = objViewModel.listArray?.firstIndex(where: {
                            $0.id == updatedObj.id
                        }) {
                            objViewModel.listArray?[index] = updatedObj
                            isChanged = true
                        }
                    }
                }

                
            }.padding(6)
            Spacer()
            
        }.background(Color(.systemGray6)).scrollIndicators(.hidden, axes: .vertical)
        
    }
}

#Preview {
    BoardInterestView()
}


struct BoardCategoryCell: View {

    let obj: CategoryModel
    let onFavouriteChange: (_ updatedObj: CategoryModel) -> Void

    @State private var isSelected = false
    private let size = UIScreen.ft_width() / 3
    private let radius: CGFloat = 15

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                AsyncImage(url: URL(string: obj.image ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("getkartplaceholder")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: size - 10, height: size)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                // 🔥 dark overlay
                RoundedRectangle(cornerRadius: radius)
                    .fill(Color.black.opacity(0.25))
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            toggleFavourite()
                        } label: {
                            Image(isSelected
                                  ? "add-square-check-rounded"
                                  : "add-square-stroke-rounded")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .padding(5)
                    }
                }
            }

            Text(obj.name ?? "")
                .font(.inter(.medium, size: 15))
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
        .onAppear {
            isSelected = obj.is_favourite ?? false
        }
    }

    private func toggleFavourite() {
        let newValue = !isSelected
        isSelected = newValue
        addToFavoriteApi(isFavorite: newValue)
    }

    private func addToFavoriteApi(isFavorite: Bool) {

        let params: [String: Any] = [
            "category_id": obj.id ?? "",
            "favourite": (isFavorite) ? 1 : 0
        ]

        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.manage_favourite_category,
            param: params,methodType:.post,
            showLoader: true
           ) { responseObject, error in

            guard error == nil,
                  let result = responseObject as? NSDictionary,
                  result["code"] as? Int == 200 else {
                return
            }

            // ✅ create updated object
            var updatedObj = obj
            updatedObj.is_favourite = isFavorite

            // ✅ callback to parent
            DispatchQueue.main.async {
                onFavouriteChange(updatedObj)
            }
        }
    }
}
