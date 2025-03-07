//
//  ItemDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/03/25.
//

import SwiftUI
import MapKit
import Foundation

struct ItemDetailView: View {
    
    
    var navController:UINavigationController?
    
    @State var itemObj:ItemModel?
    @State private var selectedIndex = 0
    @State var isLiked = false
    @StateObject private var objVM = ItemDetailViewModel()
    
    
    var body: some View {
        HStack{
            Button {
                AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                
            }.padding(.leading,10)
            
            Spacer()
            
            Button {
                
            } label: {
                Image("share").renderingMode(.template).foregroundColor(.black)
            }.padding(.trailing,10)
            
        }.frame(height: 44)
        Divider()
        Spacer()
        VStack{
            
            ScrollView{
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        
                        TabView(selection: $selectedIndex) {
                            
                            if let arr = itemObj?.galleryImages as? [GalleryImage]{
                                
                                ForEach(0..<arr.count){ index in
                                    
                                    if  let img = arr[index].image {
                                        AsyncImage(url: URL(string: img)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 200)
                                                .cornerRadius(10)
                                                .tag(index)
                                            
                                        }placeholder: { ProgressView().progressViewStyle(.circular) }
                                    }
                                }
                            }
                            
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)).tint(.orange).cornerRadius(10)
                        .frame(height: 200)
                        
                        Button(action: {
                            isLiked.toggle()
                        }) {
                            Image(isLiked ? "like_fill" : "like")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(isLiked ? .red : .gray)
                                .padding()
                        }
                    }
                    
                    // Spacer()
                  /*  HStack {
                        Spacer()
                        if let arr = itemObj?.galleryImages{
                            
//                            ForEach(arr.indices, id: \ .self) { index in
//                                
//                                // ForEach(imgArray.indices, id: \ .self) { index in
//                                Circle()
//                                    .frame(width: 8, height: 8)
//                                    .foregroundColor(selectedIndex == index ? .orange : .gray)
//                            }
                            Spacer()
                        }
                        
                    }.padding(.top, 5)
                    */
                    
                    Text(itemObj?.name ?? "''").font(Font.manrope(.medium, size: 16))
                        .font(.headline)
                        .padding(.top, 10).padding(5)
                    
                    Text("\u{20B9}\(itemObj?.price ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange).padding(5).padding(.bottom,10)
                    
                    
                    HStack{
                        HStack{
                            Image("location_icon").renderingMode(.template).foregroundColor(.orange)
                            Text(itemObj?.address ?? "").lineLimit(1)
                        }
                        Spacer()
                        Text(itemObj?.expiryDate ?? "")
                    }.padding(5).padding(.bottom,10)
               
                    let columns = [
                        GridItem(.fixed(widthScreen/2.0-20)),
                        GridItem(.fixed(widthScreen/2.0-20)),
                       ]
                    LazyVGrid(columns: columns, alignment:.leading, spacing: 15) {
                        if let arr = itemObj?.customFields{
                            ForEach(arr){obj in
                                
                                InfoView(icon: obj.image ?? "", text: obj.name ?? "",value:obj.value?.first ?? "")
                            }
                        }
                    }
                  
                    Divider()
                    VStack(alignment: .leading) {
                        Text("About this item").font(Font.manrope(.semiBold, size: 16))
                        Text(itemObj?.description ?? "")
                    }.padding(.vertical,1).padding(.horizontal,5)
                    
                    Divider().padding(.vertical)
                    SellerInfoView(name: objVM.sellerObj?.name ?? "", email: objVM.sellerObj?.email ?? "", image: objVM.sellerObj?.profile ?? "")
                    
                    Text("Location").font(Font.manrope(.semiBold, size: 16))
                        .font(.headline)
                    
                    HStack{
                        Image("location_icon").renderingMode(.template).foregroundColor(.orange)
                        Text(itemObj?.address ?? "")
                        Spacer()
                    }
                    
                    MapView(lat: itemObj?.latitude ?? 0.0, long: itemObj?.longitude ?? 0.0)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.bottom)
                  
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.red)
                            Text("Did you find any problem?").font(Font.manrope(.semiBold, size: 16))
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                      
                        
                        Text("Report this Ad")
                            .font(.subheadline)
                            .foregroundColor(.orange).frame(width: 130, height: 30)
                           .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray, lineWidth: 0.5)
                           ) .background(.yellow.opacity(0.1)).cornerRadius(15.0)
                            .onTapGesture {
                                print("Report Ad tapped")
                            }
                    }  .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.top, 5)
                    
                }
                Spacer()
                
                HStack{
                    Text("Related Ads").foregroundColor(.black).font(Font.manrope(.semiBold, size: 16))
                    Spacer()
                }.padding()
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 150))], spacing: 10){
                        
                        ForEach(objVM.relatedDataItemArray){ item in
                                                            
                            ProductCard(imageName: item.image ?? "", price: "₹\(item.price ?? 0)", title:item.name ?? "", location: item.address ?? "").frame(width: widthScreen/2.0 - 15)
                                .onTapGesture {
                                    let hostingController = UIHostingController(rootView: ItemDetailView(navController: self.navController, itemObj:item))
                                    self.navController?.pushViewController(hostingController, animated: true)
                                }
                        }
                    }
                    .padding()
                }
            }
            .padding(8)
            
            
        }.onAppear{
            
            if objVM.sellerObj == nil {
                objVM.getSeller(sellerId: self.itemObj?.userID ?? 0)
                objVM.getProductListApi(categoryId: self.itemObj?.categoryID ?? 0)
            }
        }
        
        Spacer()
        Button(action: {
            print("Make an Offer")
        }) {
            Text("Make an Offer")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding([.leading,.trailing])
    }
}


#Preview {
    ItemDetailView(navController:nil,itemObj:nil)
}


struct InfoView: View {
    let icon: String
    let text: String
    let value:String
    var body: some View {
        HStack {
      
            AsyncImage(url: URL(string: "https://adminweb.getkart.com/storage/custom-fields/66b5deb7963ec8.529669121723195063.svg")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width:40, height: 40)
                
            }placeholder: {
                
//                Image("getkartplaceholder").resizable()
//                    .scaledToFit()
//                    .frame(width:40, height: 40)
            }
            
            VStack{
                Text(text)
                    .font(.manrope(.regular, size: 12)).foregroundColor(.gray)
                Text(value)
                    .font(.manrope(.medium, size: 14)).foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}

struct SellerInfoView: View {
    let name: String
    let email: String
    let image: String
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack{
                Button {
                    
                } label: {

                    AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width:60, height: 60)
                            .cornerRadius(30)
                        
                    }placeholder: {
                        
                        Image("getkartplaceholder").resizable()
                            .scaledToFit()
                            .frame(width:60, height: 60)
                            .cornerRadius(30)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("\(name)")
                        .font(.headline)
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                
                HStack{
                    Button {
                        
                    } label: {
                        Image("message").renderingMode(.template).foregroundColor(.orange)
                    }.frame(width: 40,height: 40).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                    Button {
                        
                    } label: {
                        Image("call").renderingMode(.template).foregroundColor(.orange)
                    }.frame(width: 40,height: 40).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                    Button {
                        
                    } label: {
                        Image("arrow_right").renderingMode(.template).foregroundColor(.orange)
                  
                    }.frame(width: 20,height: 20)

                }.padding(.leading)
            }
        }
       // .padding(.vertical)
    }
}

struct MapView: View {
    let lat:Double
    let long:Double

    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: long),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }
}

struct Bike {
    let name: String
    let price: Int
    let color: String
    let kmDriven: Int
    let modelYear: Int
    let fuelType: String
    let location: String
    let seller: String
    let email: String
}





import SwiftUI
import WebKit

struct SVGWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

struct ContentView: View {
    let svgURL = URL(string: "https://adminweb.getkart.com/storage/custom-fields/66b5deb7963ec8.529669121723195063.svg")!

    var body: some View {
        SVGWebView(url: svgURL)
            .frame(width: 200, height: 200)  // Set frame size as needed
    }
}
