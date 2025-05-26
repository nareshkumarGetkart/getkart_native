//
//  MyBoostAdsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/04/25.
//

import SwiftUI
import Kingfisher
struct MyBoostAdsView: View {
    var navigation:UINavigationController?
    @StateObject var obj = MyAdsViewModel()
    
    var body: some View {
        HStack {
            
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label)).padding()
            }
            Text("My Boost Ads").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
        }.frame(height: 44).background(Color(UIColor.systemBackground))
        
        VStack{
            
            if obj.listArray.count == 0  && !obj.isDataLoading{
                
                HStack{
                    Spacer()
                    VStack(spacing: 30){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                ScrollView{
                    HStack{Spacer()}.frame(height: 10)

                    LazyVStack{
                        ForEach(obj.listArray) { item in
                            BoostAdsCell(itemObj:item)
                                .onTapGesture {
                                    var swiftVw = ItemDetailView(navController:  navigation, itemId: item.id ?? 0, itemObj: item,isMyProduct:true, slug: item.slug)
                                 
                                    
                                    swiftVw.returnValue = { value in
                                        
                                        if let obj = value{
                                            self.updateItemInList(obj)
                                        }
                                    }
                                    let hostingController = UIHostingController(rootView: swiftVw)
                                    hostingController.hidesBottomBarWhenPushed = true
                                    self.navigation?.pushViewController(hostingController, animated: true)
                                }
                                .onAppear{
                                    
                                    if let lastItem = obj.listArray.last, lastItem.id == item.id, !obj.isDataLoading {
                                        obj.getBoostAdsList()
                                    }
                                }
                        }
                    }
                    Spacer()
                }.refreshable {
                    if obj.isDataLoading == false {
                        self.obj.page = 1
                        obj.getBoostAdsList()
                    }
                }
            }
        }
        .background(Color(.systemGray6)).navigationBarHidden(true)
        
        
    }
    
    private func updateItemInList(_ value: ItemModel) {
        if let index =  obj.listArray.firstIndex(where: { $0.id == value.id }) {
            obj.listArray[index] = value
        }
    }
}

#Preview {
    MyBoostAdsView()
}


struct BoostAdsCell: View {
    var itemObj:ItemModel?
    
    var body: some View {
        
        HStack{
            
            ZStack{

                KFImage(URL(string:  itemObj?.image ?? ""))
                    .placeholder {
                        Image("getkartplaceholder")
                        .frame(width: 120,height: 140).aspectRatio(contentMode: .fit).cornerRadius(5)
                    }
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
                                                                height: widthScreen / 2.0 - 15))
                    )
                .frame(width: 120,height: 140).aspectRatio(contentMode: .fit).cornerRadius(5)

                
                VStack(alignment:.leading){
                    HStack{
                        Text("Featured")
                            .frame(width:75,height:20)
                            .background(.orange)
                            .cornerRadius(5)
                            .foregroundColor(Color(UIColor.white))
                            .font(.manrope(.regular, size: 13))
                    }.padding(.top,5)
                    Spacer()
                }
            }
            
            VStack(alignment:.leading,spacing: 2){
                HStack{
                    Text("\(Local.shared.currencySymbol) \((itemObj?.price ?? 0.0).formatNumber())").font(.custom("Manrope-Regular", size: 16.0)).foregroundColor(.orange)
                    Spacer()
                   
                  /*  Button {
                        
                    } label: {
                        Image("heart")
                    }.padding()
                    */
                }
                
                Text(itemObj?.name ?? "")
                    .font(.custom("Manrope-Regular", size: 14.0))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(UIColor.label))

                HStack{
                    Image("location-outline")
                        .renderingMode(.template)
                        .foregroundColor(Color.gray)
                    Text(itemObj?.address ?? "" ).font(.custom("Manrope-Regular", size: 12.0))
                        .foregroundColor(Color.gray)
                }.padding(.bottom,10)
            }
        }.background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal,8)
    }
}
