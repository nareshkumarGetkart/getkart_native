//
//  NotificationViewModel.swift
//

import Foundation
import SwiftUI

@MainActor
final class NotificationViewModel: ObservableObject {

    // MARK: - Published

    @Published var notifications: [NotificationModel] = []

    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var isLoadingMore = false

    @Published var showError = false
    @Published var errorMessage = ""

   // @Published var selectedSegment: NotificationSegment = .all

    // MARK: - Pagination

    private(set) var currentPage = 1
    private(set) var lastPage = 1

    // MARK: - Dependency

    private let getNotificationUseCase: GetNotificationUseCase

    init(getNotificationUseCase: GetNotificationUseCase) {
        self.getNotificationUseCase = getNotificationUseCase
    }

    // MARK: Initial Load

    func loadNotifications() {

        guard !isLoading else { return }

        isLoading = true
        currentPage = 1

        getNotificationUseCase.execute(page: currentPage) { [weak self] result in

            guard let self else { return }

            DispatchQueue.main.async {

                self.isLoading = false

                switch result {

                case .success(let response):

                    self.notifications = response.data ?? []
                    self.currentPage = response.currentPage ?? 1
                    self.lastPage = response.lastPage ?? 1

                case .failure(let error):

                    self.showError = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: Pull To Refresh

    func refresh() {

        guard !isRefreshing else { return }

        isRefreshing = true
        currentPage = 1

        getNotificationUseCase.execute(page: 1) { [weak self] result in

            guard let self else { return }

            DispatchQueue.main.async {

                self.isRefreshing = false

                switch result {

                case .success(let response):

                    self.notifications = response.data ?? []

                    self.currentPage = response.currentPage ?? 1
                    self.lastPage = response.lastPage ?? 1

                case .failure(let error):

                    self.showError = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: Pagination

    func loadMoreIfNeeded(currentItem: NotificationModel) {

        guard let lastItem = notifications.last else { return }

        guard lastItem.id == currentItem.id else { return }

        guard currentPage < lastPage else { return }

        guard !isLoadingMore else { return }

        loadMore()
    }

    private func loadMore() {

        isLoadingMore = true

        let page = currentPage + 1

        getNotificationUseCase.execute(page: page) { [weak self] result in

            guard let self else { return }

            DispatchQueue.main.async {

                self.isLoadingMore = false

                switch result {

                case .success(let response):

                    self.notifications.append(contentsOf: response.data ?? [])

                    self.currentPage = response.currentPage ?? self.currentPage
                    self.lastPage = response.lastPage ?? self.lastPage

                case .failure(let error):

                    self.showError = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
