//
//  ItemDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/03/25.
//

import SwiftUI
import MapKit
import Foundation
import SVGKit

struct ItemDetailView: View {
    
    
    var navController:UINavigationController?
    
    @State var itemObj:ItemModel?
    @State private var selectedIndex = 0
    @State var isLiked = false
    @StateObject private var objVM = ItemDetailViewModel()
    @State private var showSheet = false

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
                        GridItem(.adaptive(minimum: 100, maximum: widthScreen/2.0-10)),
                        GridItem(.adaptive(minimum: 100, maximum: widthScreen/2.0-10)),
                       ]
                    LazyVGrid(columns: columns, alignment:.leading, spacing: 5) {
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
                    
                    MapView(latitude: itemObj?.latitude ?? 0.0, longitude: itemObj?.longitude ?? 0.0,address: itemObj?.address ?? "")
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
                                
                                let destVC = UIHostingController(rootView: ReportAdsView())
                                destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
                                destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
                                destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                                self.navController?.present(destVC, animated: true, completion: nil)
                                
                                    
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
                    .padding([.leading,.trailing,.bottom])
                }
            }
            .padding(8)
            
            
        }.onAppear{
            
            if objVM.sellerObj == nil {
                objVM.getSeller(sellerId: self.itemObj?.userID ?? 0)
                objVM.getProductListApi(categoryId: self.itemObj?.categoryID ?? 0)
                objVM.setItemTotalApi(itemId: self.itemObj?.id ?? 0)
            }
               
        }
        
            .sheet(isPresented: $showSheet) {
                if #available(iOS 16.0, *) {
                    SafetyTipsView().transition(.move(edge: .bottom))
                        .presentationDetents([.medium, .medium]) // Customizable sizes
                        .presentationDragIndicator(.visible)
                } else {
                    // Fallback on earlier versions
                    
                    if showSheet {
                        SafetyTipsView()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                } // Shows the drag indicator
                    }
        
        Spacer()
        Button(action: {
            print("Make an Offer")
            showSheet = true
//
//            let destVC = UIHostingController(rootView: SafetyTipsView())
//            destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
//            destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
//            destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
//            self.navController?.present(destVC, animated: true, completion: nil)
            
               
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
            if icon.lowercased().contains(".svg"){
            SVGImageView(url: URL(string: icon)).frame(width:30, height: 30)
            }else{
               
                AsyncImage(url: URL(string: icon)) { image in
                     image
                         .resizable()
                         .scaledToFit()
                         .frame(width:30, height: 30)
                     
                 }placeholder: {
                     
                     Image("getkartplaceholder").resizable()
                         .scaledToFit()
                         .frame(width:30, height: 30)
                 }
            }
       
            VStack(alignment: .leading){
                Spacer()
                Text(text)
                    .font(.manrope(.regular, size: 10)).foregroundColor(.gray)
                Text(value)
                    .font(.manrope(.medium, size: 14)).foregroundColor(.black)
                Spacer()

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

//struct MapView: View {
//    let lat:Double
//    let long:Double
//
//    var body: some View {
//        Map(coordinateRegion: .constant(MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: lat, longitude: long),
//            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        )))
//    }
//}









import MapKit

struct MapView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double
    let address: String

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)

        // 📌 Add marker (annotation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = address
        mapView.addAnnotation(annotation)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {}
}
