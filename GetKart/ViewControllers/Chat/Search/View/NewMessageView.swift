//
//  NewMessageView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/05/26.
//

import SwiftUI

struct NewMessageView: View {

    var navigationController: UINavigationController?

    @State private var searchText: String = ""
    @State private var selectedUser: ChatUser? = nil
    @State private var isViewVisible = false

    @StateObject private var searchService = ChatSearchVM(isGlobaSearch: true)

    @State private var debounceTimer: Timer? = nil

    var body: some View {

        ZStack(alignment: .top) {

            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ──────────────────────────────
                CustomHeaderView(
                    title: "New message",
                    showBack: true,
                    rightImage: nil,
                    onBack: {
                        navigationController?.popViewController(animated: true)
                    },
                    onRightTap: nil
                )

                // ── Search Bar ──────────────────────────────
                ToSearchBarView(text: $searchText)
                    .background(Color(.systemGroupedBackground))
                    .onChange(of: searchText) { newValue in

                        debounceTimer?.invalidate()

                        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                            searchService.search(query: newValue)
                        }
                    }

                Divider()

                // ── User List ──────────────────────────────
                List {
                    ForEach(searchService.users) { user in
                        ChatUserRowView(user: user)
                            .listRowSeparator(.hidden)
                            .background(Color(.systemGroupedBackground))
                            .listRowBackground(Color.clear) // clear row bg
                            .listRowInsets(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
                            .onTapGesture {
                                if selectedUser?.id != user.id {
                                    selectedUser = user
                                    createRoom()
                                }
                            }
                            .onAppear {
                                if searchService.shouldLoadMore(currentUser: user) {
                                    searchService.loadMore(query: searchText)
                                }
                            }
                    }

                    // Footer Loader for pagination
                    if searchService.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.clear))

                // First Loading (Full Screen)
                if searchService.isLoading && searchService.users.isEmpty {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Searching...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }

                // Empty State
                if !searchService.isLoading &&
                    searchService.users.isEmpty &&
                    !searchText.isEmpty {

                    VStack(spacing: 8) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)

                        Text("No users found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)

                        Text("Try a different name")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.top, 60)
                }

                // Error State
                if let error = searchService.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 36))
                            .foregroundColor(.orange)

                        Text("Something went wrong")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)

                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button("Retry") {
                            searchService.search(query: searchText)
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    }
                    .padding(.top, 60)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            isViewVisible = true

        }
        .onDisappear {
            searchService.cancel()
            debounceTimer?.invalidate()
            selectedUser = nil
            isViewVisible = false
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(SocketEvents.createRoom.rawValue))) { notification in

            if isViewVisible == false{
                
                return
            }
            guard let data = notification.userInfo else { return }

            if let dataDict = data["data"] as? Dictionary<String, Any> {

                let id = dataDict["id"] as? Int ?? 0
                let receiver_id = dataDict["receiver_id"] as? Int ?? 0

                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = id
                destVC.userId = receiver_id

                self.navigationController?.pushViewController(destVC, animated: true)
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true

            }
            else {
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = 0
                destVC.userId = selectedUser?.id ?? 0
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        }
    }

    // MARK: - Create Room
    func createRoom() {
        FaceBookAppEvents.facebookEvents(type: .createOffer, categoryName: selectedUser?.name ?? "")
        let params = ["user_id": selectedUser?.id ?? 0] as [String: Any]
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.createRoom.rawValue, params)
    }
}

// MARK: - To: Search Bar
struct ToSearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text("To:")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary).padding(.leading)
            
            TextField("Search User", text: $text)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .font(.system(size: 16))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(8)
             
        }
       // .padding(.horizontal, 14)
        .frame(height: 45)
        .background(Color(.systemBackground))
        //.cornerRadius(12)
       // .padding(.horizontal, 14)
    }
}

// MARK: - Custom Header
struct CustomHeaderView: View {
    var title: String
    var showBack: Bool = true
    var rightImage: String?
    var onBack: (() -> Void)?
    var onRightTap: (() -> Void)?
    
    var body: some View {
        HStack {
            if showBack {
                Button { onBack?() } label: {
                    Image("arrow_left").renderingMode(.template)
                        .foregroundColor(.primary)
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(width: 40, height: 40)
            } else {
                Spacer().frame(width: 40, height: 40)
            }
            
           
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if let rightImage = rightImage {
                Button { onRightTap?() } label: {
                    Image(systemName: rightImage)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(width: 40, height: 40)
            } else {
                Spacer().frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 50)
        .background(Color(.systemBackground))
    }
}


// MARK: - Preview
#Preview {
    NewMessageView()
}
