//
//  SearchMessagedUserView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/05/26.
//

import SwiftUI

struct SearchMessagedUserView: View{
    var navigationController: UINavigationController?
    
    @State private var searchText: String = ""
    @State private var selectedUser: ChatUser? = nil
    @StateObject private var searchService = ChatSearchVM(isGlobaSearch: false)
    @State private var debounceTimer: Timer? = nil

  
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // ── Fixed Header ──────────────────────────────
                CustomHeaderView(
                    title: "Chats",
                    showBack: true,
                    rightImage: nil,
                    onBack: {
                        navigationController?.popViewController(animated: true)
                    },
                    onRightTap: nil
                )
                
                // ── Fixed To: Bar (never scrolls) ─────────────
                ChatSearchBarView(text: $searchText)
                //.padding(.top, 10)
                // .padding(.bottom, 10)
                    .background(Color(.systemGroupedBackground))
                    .onChange(of: searchText) { newValue in
                        // Debounce: wait 400ms after user stops typing
                        debounceTimer?.invalidate()
                        debounceTimer = Timer.scheduledTimer(
                            withTimeInterval: 0.4,
                            repeats: false
                        ) { _ in
                            searchService.page = 1
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
                .background(Color.clear) // list background clear

                // Loading State
                if searchService.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
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
        .onDisappear {
            searchService.cancel()
            debounceTimer?.invalidate()
            selectedUser = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(SocketEvents.createRoom.rawValue))) { notification in
            
            if navigationController?.topViewController is ChatVC {
                return
            }
            
            guard let data = notification.userInfo else{
                return
            }
            
            if let dataDict = data["data"] as? Dictionary<String,Any>{
                
                let id = dataDict["id"] as? Int ?? 0
                let sender_id = dataDict["sender_id"] as? Int ?? 0
                let receiver_id = dataDict["receiver_id"] as? Int ?? 0
                
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = id
                destVC.userId = receiver_id
                self.navigationController?.pushViewController(destVC, animated: true)
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
            }
            else{
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = 0
                destVC.userId = selectedUser?.id ?? 0
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        }
    }
    
    // MARK: - Pagination Trigger
        private func triggerLoadMoreIfNeeded(user: ChatUser) {
            guard let lastUser = searchService.users.last,
                  lastUser.id == user.id,
                  !searchService.isLoading else { return }

            // Load next page with current query
            searchService.search(query: searchText)
        }
    
    func createRoom(){
        
        FaceBookAppEvents.facebookEvents(type: .createOffer, categoryName: selectedUser?.name ?? "")
        let params = ["user_id":selectedUser?.id ?? 0] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.createRoom.rawValue, params)
    }
}

#Preview {
    SearchMessagedUserView()
}



import SwiftUI

struct ChatSearchBarView: View {

    @Binding var text: String

    var body: some View {
        VStack{
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text("Search")
                        .foregroundColor(.gray.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.bottom, 5)
                .padding(.horizontal, 10)
            Divider()
        }.background(Color(.systemBackground))
       
    }
}






struct ChatUserRowView: View {

    let user: ChatUser

    var body: some View {
        HStack(spacing: 12) {

            AsyncImage(url: URL(string: user.profile ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackAvatar
                case .empty:
                    fallbackAvatar
                @unknown default:
                    fallbackAvatar
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            Text(user.name ?? "")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 70)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 14)
    }
    
    private var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray4))
            Text(String(user.name!.prefix(1)).uppercased())
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}




extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: SwiftUI.Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {

        ZStack(alignment: alignment) {
            placeholder()
                .opacity(shouldShow ? 1 : 0)

            self
        }
    }
}
