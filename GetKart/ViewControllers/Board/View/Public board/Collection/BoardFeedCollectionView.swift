//
//  BoardFeedCollectionView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/05/26.
//


import SwiftUI

struct BoardFeedCollectionView: UIViewControllerRepresentable {

    var items: [ItemModel]   // ✅ NOT Binding

    var onLoadNextPage: () -> Void
    var onTapItem: (ItemModel) -> Void
    var onOpenURL: (URL) -> Void
    var onRefresh: () -> Void

    func makeUIViewController(context: Context) -> BoardFeedCollectionVC {

        let vc = BoardFeedCollectionVC()

        vc.onLoadNextPage = onLoadNextPage
        vc.onTapItem = onTapItem
        vc.onOpenURL = onOpenURL
        vc.onRefresh = onRefresh

        return vc
    }

    func updateUIViewController(_ uiViewController: BoardFeedCollectionVC, context: Context) {
        uiViewController.updateItems(items)
    }
}
