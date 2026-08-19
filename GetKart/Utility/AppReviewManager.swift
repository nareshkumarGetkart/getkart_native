//
//  AppReviewManager.swift
//  GetKart
//
//  Created by gurmukh on 13/08/26.
//

import StoreKit
import UIKit

final class AppReviewManager {

    static let shared = AppReviewManager()

    private let lastRequestDateKey = "AppReview_LastRequestDate"
    private let reviewInterval: TimeInterval = 3 * 24 * 60 * 60

    private init() {}

    func requestReviewIfNeeded() {

        let defaults = UserDefaults.standard

        // First appearance → show immediately
        guard let lastRequestDate = defaults.object(
            forKey: lastRequestDateKey
        ) as? Date else {

            showReviewRequest()
            return
        }

        // Already requested → wait 3 days
        let timeSinceLastRequest =
            Date().timeIntervalSince(lastRequestDate)

        guard timeSinceLastRequest >= reviewInterval else {
            return
        }

        showReviewRequest()
    }

    private func showReviewRequest() {

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene else {
            return
        }

        // Store request date
        UserDefaults.standard.set(
            Date(),
            forKey: lastRequestDateKey
        )

        SKStoreReviewController.requestReview(in: scene)
    }
}
