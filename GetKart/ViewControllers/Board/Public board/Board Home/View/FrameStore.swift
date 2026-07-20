//
//  FrameStore.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/07/26.
//

import Foundation

final class FrameStore: ObservableObject {

    private var frames: [Int: CGRect] = [:]
    private var visibilityWorkItem: DispatchWorkItem?

    func set(id: Int, frame: CGRect) {
        frames[id] = frame
    }

    func remove(id: Int) {
        frames.removeValue(forKey: id)
    }

    func removeAll() {
        frames.removeAll()
    }

    func scheduleVisibilityUpdate(isActive: Bool) {
        visibilityWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.calculateVisibleVideos(isActive: isActive)
        }
        visibilityWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
    }

    private func calculateVisibleVideos(isActive: Bool) {
        guard isActive else { FeedVideoManager.shared.pauseAll(); return }

        let screenH = UIScreen.main.bounds.height
        var visible: Set<Int> = []

        for (id, frame) in frames {
            guard frame.maxY > 0, frame.minY < screenH else { continue }
            let visH = min(frame.maxY, screenH) - max(frame.minY, 0)
            if frame.height > 0, (visH / frame.height) >= 0.6 {
                visible.insert(id)
            }
        }

        FeedVideoManager.shared.updatePlayback(visibleIDs: visible)
    }
}
