//
//  BoardStoreNew.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/06/26.
//

import Foundation
import AVFoundation
import Kingfisher

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
