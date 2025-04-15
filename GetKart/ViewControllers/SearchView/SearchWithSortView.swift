//
//  SearchWithSortView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/04/25.
//

import SwiftUI

struct SearchWithSortView: View {
    @State private var isGridView = true
    var navigationController:UINavigationController?
    @State var categroryId = 0
    @State var categoryName = "Motorcycles and Scooters"
    
    var body: some View {
        
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text(categoryName).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background()
        
        
            VStack {
                // Search & View Toggle
                HStack {
                    TextField("Search any item...", text: .constant(""))
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Spacer()
                    
                    // Toggle button
                    Button(action: {
                        isGridView = true
                    }) {
                        Image(systemName:"square.grid.2x2")
                            .padding(8)
                    }.tint((isGridView) ? .black : .gray)
                    
                    Button(action: {
                        isGridView = false
                    }) {
                        Image(systemName:"list.bullet")
                            .padding(8)
                    }.tint((isGridView) ? .gray : .black)
                }
                .padding(.horizontal)

                // Listings
                ScrollView {
                    if isGridView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(sampleListings, id: \.id) { item in
                                GridListingCard(item: item)
                            }
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(sampleListings, id: \.id) { item in
                                ListListingCard(item: item)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer()
                // Bottom bar
                HStack {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filter")
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort by")
                    }
                    .frame(maxWidth: .infinity)
                }.frame(height: 50)
                .background(Color.white.shadow(radius: 2))
            }.navigationBarHidden(true)

    }
}


#Preview {
    SearchWithSortView()
}


// MARK: - Grid Card View
struct GridListingCard: View {
    let item: ListingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(12)

                Circle()
                    .fill(Color.white)
                    .shadow(radius: 2)
                    .frame(width: 34, height: 34)
                    .overlay(Image(systemName: "heart")
                        .foregroundColor(.orange))
                    .offset(x: -8, y: -8)
            }

            Text("₹ \(item.price)")
                .font(.headline)
                .foregroundColor(.orange)

            Text(item.title)
                .font(.subheadline)
                .lineLimit(1)

            HStack {
                Image(systemName: "location")
                Text(item.location)
                    .lineLimit(1)
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

// MARK: - List Card View
struct ListListingCard: View {
    let item: ListingItem

    var body: some View {
        HStack(alignment: .top) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 110)
                .cornerRadius(12)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text("₹ \(item.price)")
                    .font(.headline)
                    .foregroundColor(.orange)

                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(1)

                HStack {
                    Image(systemName: "location")
                    Text(item.location)
                        .lineLimit(1)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }

            Spacer()

            Circle()
                .fill(Color.white)
                .shadow(radius: 2)
                .frame(width: 34, height: 34)
                .overlay(Image(systemName: "heart")
                    .foregroundColor(.orange))
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

// MARK: - Sample Data
struct ListingItem {
    let id = UUID()
    let imageName: String
    let price: String
    let title: String
    let location: String
}

let sampleListings = [
    ListingItem(imageName: "bike1", price: "120000.0", title: "Chethak ev new premium", location: "Pandurangapuram, Visakhapatnam"),
    ListingItem(imageName: "bike2", price: "150000.0", title: "KTM Duke 200", location: "Brodipet, Guntur, Andhra Pradesh, India"),
    ListingItem(imageName: "bike3", price: "80000.0", title: "Ns 125 Blue Colour Full Condition", location: "Yemmiganur, Andhra Pradesh, India"),
]
