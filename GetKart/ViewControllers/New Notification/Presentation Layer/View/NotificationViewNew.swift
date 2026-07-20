//
//  NotificationViewNew.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

import SwiftUI

struct NotificationViewNew: View {

    @StateObject var viewModel: NotificationViewModel

    var body: some View {

        VStack(spacing: 0) {

            // MARK: Segment

//            NotificationSegmentControl(
//                selectedSegment: $viewModel.selectedSegment
//            )
//            .padding(.horizontal)
//            .padding(.top, 10)
//
//            Divider()

            // MARK: Content

            contentView
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {

            if viewModel.notifications.isEmpty {
                viewModel.loadNotifications()
            }
        }
        .refreshable {

            viewModel.refresh()

        }
        .alert("Error",
               isPresented: $viewModel.showError) {

            Button("OK", role: .cancel) {}

        } message: {

            Text(viewModel.errorMessage)

        }
    }

    // MARK: Content

    @ViewBuilder
    private var contentView: some View {

        if viewModel.isLoading {

            ProgressView()
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)

        } else if viewModel.notifications.isEmpty {

            EmptyNotificationView()

        } else {

            ScrollView {

                LazyVStack(spacing: 0) {

                    ForEach(viewModel.notifications) { notification in

                        NotificationCell(notification: notification)
                            .onAppear {

                                viewModel.loadMoreIfNeeded(
                                    currentItem: notification
                                )

                            }

                        Divider()
                            .padding(.leading, 70)

                    }

                    if viewModel.isLoadingMore {

                        ProgressView()
                            .padding()

                    }

                }

            }

        }

    }

}
