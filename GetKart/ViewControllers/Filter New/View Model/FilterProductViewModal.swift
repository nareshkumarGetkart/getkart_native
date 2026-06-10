//
//  FilterProductViewModal.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/06/26.
//

import Foundation

final class FilterProductViewModal: ObservableObject {

    @Published var selectedCategory = 0
    @Published var selectedOption: String?

    let categories: [FilterCategory] = [
        .init(title: "Price", count: "1"),
        .init(title: "New Arrivals", count: nil)
    ]

    let priceOptions: [FilterOption] = [
        .init(title: "Rs. 999 and Below", itemCount: "120+ items"),
        .init(title: "Rs. 1500 - Rs. 1999", itemCount: "150+ items"),
        .init(title: "Rs. 2000 - Rs. 2999", itemCount: "1k+ items"),
        .init(title: "Rs. 3000 - Rs. 3999", itemCount: "1.2k+ items"),
        .init(title: "Rs. 4000 - Rs. 5999", itemCount: "2.7k+ items"),
        .init(title: "Rs. 6000 and Above", itemCount: "5.9k+ items")
    ]
}

struct FilterCategory: Identifiable {
    let id = UUID()
    let title: String
    let count: String?
}

struct FilterOption: Identifiable {
    let id = UUID()
    let title: String
    let itemCount: String
}
