//
//  ChatSearchViewModal.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/05/26.
//



/*
import SwiftUI

// MARK: - Search Service
class ChatSearchVM: ObservableObject {
    @Published var users: [ChatUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    var isGlobalSearch = true
    private var searchTask: Task<Void, Never>? = nil
    // Add this published property to ChatSearchVM
    @Published var isLoadingMore: Bool = false

    var page = 1
    init(isGlobaSearch:Bool){
        self.isGlobalSearch = isGlobaSearch
    }
    func search(query: String) {
        // Cancel previous task
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            DispatchQueue.main.async {
                self.page = 1
                self.users = []
                self.isLoading = false
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        searchTask = Task {
            await performSearch(query: query)
        }
    }
    
    private func performSearch(query: String) async {
        
        var strUrl = Constant.shared.search_global_users + "?search=\(query)&page=\(page)"
        if !isGlobalSearch{
             strUrl = Constant.shared.search_room_users + "?search=\(query)&page=\(page)"
        }
       
        if page == 1{
            DispatchQueue.main.async {
                self.users.removeAll()
            }
        }
      
        ApiHandler
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl ) { (obj:UserChatParse) in
            
            if obj.code == 200{
                
                if let arrObj = obj.data?.data{
                    self.users.append(contentsOf: arrObj)
                    self.page += 1
                }
            }else{
                
                
            }
            self.isLoading = false

        }
       
    }
    
    func cancel() {
        searchTask?.cancel()
        isLoading = false
    }
    
    // Add inside ChatSearchVM
    func loadMore(query: String) {
        guard !isLoading, !isLoadingMore else { return }
        isLoadingMore = true
        searchTask = Task {
            await performSearch(query: query)
            await MainActor.run { self.isLoadingMore = false }
        }
    }
}
*/

import Foundation
import Alamofire

class ChatSearchVM: ObservableObject {

    @Published var users: [ChatUser] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String? = nil

    var isGlobalSearch = true
    var page = 1

    private var activeRequest: DataRequest? = nil
    private var currentSearchToken: Int = 0

    private var canLoadMore = true
    private var lastPaginationTriggerId: Int? = nil   // ✅ main fix

    init(isGlobaSearch: Bool) {
        self.isGlobalSearch = isGlobaSearch
    }

    func search(query: String) {

        cancelActiveRequests()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            DispatchQueue.main.async {
                self.page = 1
                self.users = []
                self.isLoading = false
                self.isLoadingMore = false
            }
            return
        }

        // reset pagination
        page = 1
        canLoadMore = true
        lastPaginationTriggerId = nil

        currentSearchToken += 1
        let token = currentSearchToken

        DispatchQueue.main.async {
            self.users = []
            self.isLoading = true
            self.errorMessage = nil
        }

        performSearch(query: trimmed, token: token, isLoadMore: false)
    }

    func loadMore(query: String) {

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return }
        guard canLoadMore else { return }
        guard !isLoading, !isLoadingMore else { return }

        DispatchQueue.main.async {
            self.isLoadingMore = true
        }

        let token = currentSearchToken
        performSearch(query: trimmed, token: token, isLoadMore: true)
    }

    private func performSearch(query: String, token: Int, isLoadMore: Bool) {

        var strUrl = Constant.shared.search_global_users + "?search=\(query)&page=\(page)"
        if !isGlobalSearch {
            strUrl = Constant.shared.search_room_users + "?search=\(query)&page=\(page)"
        }

        activeRequest?.cancel()

        let request = ApiHandler.sharedInstance.makeGetGenericDataWithReturn(
            isToShowLoader: false,
            url: strUrl
        ) { [weak self] (obj: UserChatParse) in

            guard let self = self else { return }

            guard token == self.currentSearchToken else {
                return
            }

            DispatchQueue.main.async {

                if obj.code == 200 {
                    let newUsers = obj.data?.data ?? []

                    if isLoadMore {
                        self.users.append(contentsOf: newUsers)
                    } else {
                        self.users = newUsers
                    }

                    if newUsers.isEmpty {
                        self.canLoadMore = false   // ✅ stop pagination
                    } else {
                        self.page += 1
                    }

                    self.errorMessage = nil
                } else {
                    self.errorMessage = obj.message ?? "Something went wrong"
                }

                self.isLoading = false
                self.isLoadingMore = false
            }
        }

        self.activeRequest = request
    }

    func shouldLoadMore(currentUser: ChatUser) -> Bool {
        guard let last = users.last else { return false }
        guard last.id == currentUser.id else { return false }
        guard lastPaginationTriggerId != currentUser.id else { return false } // ✅ stop multiple calls
        lastPaginationTriggerId = currentUser.id
        return true
    }

    func cancel() {
        cancelActiveRequests()
    }

    private func cancelActiveRequests() {
        activeRequest?.cancel()
        activeRequest = nil
        isLoading = false
        isLoadingMore = false
    }
}
