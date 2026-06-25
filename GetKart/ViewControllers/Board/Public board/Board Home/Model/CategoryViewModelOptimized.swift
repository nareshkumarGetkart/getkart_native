//
//  CategoryViewModelOptimized.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/06/26.
//

import Foundation

// MARK: - CategoryViewModel (optimized)
class CategoryViewModelOptimized: ObservableObject {
    
    @Published var listArray: [CategoryModel]?
    weak var delegate: RefreshScreen?
    private var page = 1
    var isDataLoading = true
    private var ismoreDataAvailable = true
    private var catType: Int

    init(type: Int = 1, isToShowLoader: Bool = true) {
        catType = type
        // ✅ FIX 1: Pre-seed the "All" stub immediately — no API wait.
        // BoardHomeView starts with selectedCategoryId = 55555 and can
        // render the skeleton / begin loading the feed right away.
        listArray = [Self.allCategory]
        getCategoriesListApi(showLoader: isToShowLoader)
    }

    // ✅ Shared "All" stub so we never construct it in two places
    static let allCategory = CategoryModel(
        id: 55555,
        sequence: nil,
        name: "All",
        image: "",
        parentCategoryID: nil,
        description: nil,
        status: nil,
        createdAt: nil,
        updatedAt: nil,
        slug: nil,
        subcategoriesCount: nil,
        allItemsCount: nil,
        translatedName: nil,
        translations: nil,
        subcategories: []
    )

    func getCategoriesListApi(showLoader: Bool = true) {
        guard ismoreDataAvailable else { return }

        let strUrl = Constant.shared.get_categories + "?page=\(page)&type=\(catType)"
        isDataLoading = true
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: showLoader, url: strUrl) { [weak self] (obj: CategoryParse) in
            guard let self else { return }
            guard let data = obj.data?.data else { return }

            self.ismoreDataAvailable = data.count > 4

            if self.page == 1 {
                // ✅ FIX 2: Merge API result with the pre-seeded "All" stub
                // instead of re-inserting unconditionally (avoids a duplicate
                // if the server ever returns id 55555).
                self.setCategories(data)
            } else {
                self.listArray?.append(contentsOf: data)
            }

            self.delegate?.refreshScreen()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isDataLoading = false
                self.page += 1
            }
        }
    }

    func setCategories(_ apiList: [CategoryModel]) {
        var list = apiList
        // Guard prevents a duplicate "All" row if called more than once
        if list.first?.id != 55555 {
            list.insert(Self.allCategory, at: 0)
        }
        listArray = list
    }
}
