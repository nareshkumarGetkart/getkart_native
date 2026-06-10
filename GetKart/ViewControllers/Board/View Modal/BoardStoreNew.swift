//
//  BoardStoreNew.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 03/06/26.
//

import Foundation
import Kingfisher
import AVKit


// MARK: - BoardStoreNew (fixed)
@MainActor
final class BoardStoreNew: ObservableObject {
    
    @Published private(set) var boardVMs: [Int: BoardViewModelNew] = [:]
    
    
    func vm(for categoryId: Int) -> BoardViewModelNew {
        if let vm = boardVMs[categoryId] {
            return vm
        }
        let vm = BoardViewModelNew(categoryId: categoryId)
        DispatchQueue.main.async {
            self.boardVMs[categoryId] = vm
        }
        return vm
    }
    
    
    // ADD THIS inside the class body (not an extension) so it can mutate boardVMs
    @MainActor
    func evict(id: Int) {
        FeedVideoManager.shared.pauseAll()
       // boardVMs[id]?.clearItems()
        // Optional: fully remove VM so it reloads fresh on re-open
        // boardVMs.removeValue(forKey: id)
        
        // force cleanup
        ImageCache.default.clearMemoryCache()
        
       // FeedVideoManager.shared.reset()
        FeedVideoManager.shared.clearAll()
        
    }
    func preWarm(categoryId: Int) {
        vm(for: categoryId).loadIfNeeded()
    }
}


/*@MainActor
final class BoardStoreNew: ObservableObject {

    // ✅ Not @Published — views never need to observe the dictionary
    // directly. BoardListViewNew observes its own VM via @ObservedObject.
    // The @Published was the root cause: any dict write during render
    // triggered "Publishing changes from within view updates".
    private var boardVMs: [Int: BoardViewModelNew] = [:]

    init() {
        let allVM = BoardViewModelNew(categoryId: 55555)
        boardVMs[55555] = allVM
        allVM.loadIfNeeded()
    }

    func vm(for categoryId: Int) -> BoardViewModelNew {
        if let existing = boardVMs[categoryId] {
            return existing
        }
        let vm = BoardViewModelNew(categoryId: categoryId)
        boardVMs[categoryId] = vm   // safe — no @Published, no SwiftUI notification
        return vm
    }

    func preWarm(categoryId: Int) {
        vm(for: categoryId).loadIfNeeded()
    }

    func evict(id: Int) {
        guard id != 55555 else { return }
        FeedVideoManager.shared.pauseAll()
        FeedVideoManager.shared.clearAll()
        ImageCache.default.clearMemoryCache()
        boardVMs.removeValue(forKey: id)
    }
}*/
