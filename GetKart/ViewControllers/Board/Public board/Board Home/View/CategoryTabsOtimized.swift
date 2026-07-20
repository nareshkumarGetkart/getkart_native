//
//  CategoryTabsOtimized.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/07/26.
//

import SwiftUI


//MARK: - Category Optimized
struct CategoryTabsOtimized: View {

    @Binding var selected: String
    @Binding var selectedCategoryId: Int
    @ObservedObject var categoryVM: CategoryViewModelOptimized
    @Environment(\.scrollToTopProxy) private var scrollToTopProxy
    @State private var categoryScrollProxy: ScrollViewProxy?

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                            categoryTab(cat)
                                .id(cat.id)
                                .onTapGesture {
                                    selectCategory(cat, proxy: proxy)
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                }
                .onAppear {
                    categoryScrollProxy = proxy
                    //  Scroll to the already-selected "All" tab on first appear
                    // (proxy is ready now; selectedCategoryId is already 55555)
                    scrollCategoryToCenter(selectedCategoryId, proxy: proxy)
                }
            }
            Divider()
        }
        //  When the full category list arrives from the API, just scroll to
        // the current selection — no list mutation, no ID reset needed.
        .onChange(of: categoryVM.listArray?.count) { _ in
            scrollCategoryToCenter(selectedCategoryId)
        }
        // Keeps the tab bar in sync when the parent changes the selection
        // (e.g. swipe gesture in BoardHomeView)
        .onChange(of: selectedCategoryId) { newId in
            scrollCategoryToCenter(newId)
        }
    }

    // MARK: - Actions

    private func selectCategory(_ cat: CategoryModel, proxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            selectedCategoryId = cat.id ?? 0
            selected = cat.name ?? ""
            proxy.scrollTo(cat.id, anchor: .center)
            scrollToTopProxy?.scrollTo("TOP", anchor: .top)
        }
    }

    // Overload used by onChange (proxy captured in state)
    private func scrollCategoryToCenter(_ id: Int) {
        guard let proxy = categoryScrollProxy else { return }
        scrollCategoryToCenter(id, proxy: proxy)
    }

    private func scrollCategoryToCenter(_ id: Int, proxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            proxy.scrollTo(id, anchor: .center)
        }
    }

    // MARK: - UI

    private func categoryTab(_ cat: CategoryModel) -> some View {
        let isSelected = selectedCategoryId == cat.id
        return VStack(spacing: 6) {
            Text(cat.name ?? "")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .primary : .secondary) //  visual clarity
            Rectangle()
                .fill(isSelected ? Color.orange : .clear)
                .frame(height: 3)
        }
        .contentShape(Rectangle())
    }
}


//#Preview {
//    CategoryTabsOtimized()
//}
