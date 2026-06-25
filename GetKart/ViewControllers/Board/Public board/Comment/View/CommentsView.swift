//
//  CommentsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 26/02/26.
//

import SwiftUI

struct CommentsView: View {

    var onClose:((_ isToProfilePpen:Bool,_ user:User?) -> Void)?
    let itemObj:ItemModel?
    var navController:UINavigationController?

    @State private var commentText: String = ""
    @State private var replyingTo: String? = nil
    @State private var isFocused: Bool = false

    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var objVM = CommentViewModel()

    @State private var replyCommentId = 0
    @State private var textHeight: CGFloat = 35
    @State private var selectedCommentObj:CommentModel?
    @State private var showActionSheet = false
    @State private var confirmationType: ConfirmationType?
    @State private var selectedUser: User?

    var body: some View {

        VStack(spacing:0) {

            /// HEADER
            headerView

            /// COMMENTS LIST
            ScrollViewReader { proxy in

                ScrollView {

                    if $objVM.commentsArray.count == 0{
                        //Show empty view
                        emptyView.padding(.top,100)
                   
                    }else{
                        //Coments
                        LazyVStack(spacing:20) {

                            ForEach($objVM.commentsArray) { $comment in

                                CommentRow(
                                    comment: $comment,

                                    onReply: {
                                        replyingTo = comment.user?.name ?? ""
                                        isFocused = true
                                        replyCommentId = comment.id ?? 0
                                    },

                                    onLikeDislike: { commentId,isLiked in

                                        if isLiked {
                                            objVM.likeComment(comment_id: commentId)
                                        } else {
                                            objVM.unlikeComment(comment_id: commentId)
                                        }
                                    },

                                    loadMoreReplies: { commentId in
                                        loadReplies(commentId: commentId)
                                    },

                                    selectedOption:{ objComment in
                                        selectedCommentObj = objComment
                                        showActionSheet = true
                                    },

                                    selectedUser:{ user in
                                        selectedUser = user
                                    }
                                )
                                .id(comment.id)
                            }

                            Spacer().frame(height:20)
                        }
                        .padding()
                    }
                   
                }
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        isFocused = false
                    }
                )
                .onChange(of: keyboard.height) { _ in
                  //  scrollToBottom(proxy: proxy)
                }
            }
        }

        /// INPUT BAR STICKY ABOVE KEYBOARD
        .safeAreaInset(edge: .bottom) {
            inputBar
                .background(.ultraThinMaterial)
        }

        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)

        .onAppear {

            if objVM.commentsArray.isEmpty {
                objVM.getComment(itemId: itemObj?.id ?? 0)
            }
        }

        .onDisappear {

            if objVM.totalCommentCount >= 0 {
                postNotificationToUpdateCommentInBoard()
            }
        }

        /// ACTION SHEET
        .confirmationDialog(
            "",
            isPresented: $showActionSheet,
            titleVisibility: .hidden
        ) {

            if selectedCommentObj?.user?.id == Local.shared.getUserId() {

                Button("Edit") {
                    commentText = selectedCommentObj?.comment ?? ""
                    isFocused = true
                }

                Button("Delete") {
                    confirmationType = .deleteComment
                }

            } else {

                Button("Report") {}

                Button("Block User") {
                    confirmationType = .blockUser
                }
            }

            Button("Cancel", role: .cancel) {}
        }

        /// CONFIRMATION SHEET
        .sheet(item: $confirmationType) { type in

            if let obj = selectedCommentObj?.user {

                ConfirmationView(
                    user: obj,
                    confirmType: type,

                    onCancel: {
                        confirmationType = nil
                    },

                    onDone: {

                        if type == .deleteComment {

                            if (selectedCommentObj?.parentID ?? 0) > 0 {

                                objVM.deleteReply(
                                    comment_id: selectedCommentObj?.id ?? 0,
                                    parentId: selectedCommentObj?.parentID ?? 0
                                )

                            } else {

                                objVM.deleteComment(
                                    comment_id: selectedCommentObj?.id ?? 0
                                )
                            }

                        } else if type == .blockUser {

                        }

                        confirmationType = nil
                    }
                )
                .presentationDetents([.height(220)])
                .presentationCornerRadius(30)
                .presentationDragIndicator(.hidden)
            }
        }

        /// PROFILE VIEW
        .sheet(item: $selectedUser) { user in
            SellerProfileView(
                navController: navController,
                userId: user.id ?? 0
            )
        }
    }
}

private var emptyView: some View {
    VStack(spacing: 20) {
        Spacer()
        Image("no_chat_found")
        Text("No any Comments")
            .foregroundColor(.orange)
        Spacer()
    }
}
private extension CommentsView {

    var headerView: some View {

        VStack {

            HStack {

                Spacer()

                Text("Comments")
                    .font(.system(size:18,weight:.semibold))

                Spacer()

                Button {
                    onClose?(false,nil)
                } label: {

                    Image(systemName:"xmark")
                        .font(.system(size:16,weight:.medium))
                        .foregroundColor(.black)
                }
            }
            .padding()

            Divider()
        }
    }
}

private extension CommentsView {

    var inputBar: some View {

        VStack(spacing:0) {

            /// Reply banner
            if replyCommentId > 0 {

                HStack {

                    Text("Replying to @\(replyingTo ?? "")")
                        .font(.system(size:13))

                    Spacer()

                    Button("Cancel") {

                        commentText = ""
                        replyCommentId = 0
                        replyingTo = ""

                    }
                    .foregroundColor(.orange)
                    .font(.system(size:15,weight:.semibold))
                }
                .padding()
                .background(.ultraThinMaterial)
            }

            HStack(alignment:.bottom,spacing:8) {

                GrowingTextViewNew(
                    text:$commentText,
                    dynamicHeight:$textHeight,
                    isFocused:$isFocused
                )
                .frame(height:textHeight)
                .overlay(

                    Group {

                        if commentText.isEmpty {

                            Text("Add a Comment")
                                .foregroundColor(.gray)
                                .padding(.leading,12)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment:.leading
                )
                .padding(.horizontal,5)
                .padding(.vertical,5)
                .background(
                    RoundedRectangle(cornerRadius:17.5)
                        .stroke(Color.gray,lineWidth:1)
                )
                .frame(maxWidth:.infinity)

                if !commentText.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty {

                    Button {

                        sendComment()
                        textHeight = 35

                    } label: {

                        Image("msg_send_icon")
                            .renderingMode(.template)
                            .foregroundColor(.primary)
                    }
                    .frame(width:40,height:40)
                }
            }
            .padding(.horizontal)
            .padding(.vertical,5)
        }
    }
}


private extension CommentsView {

    func loadReplies(commentId: Int) {
        objVM.getReplies(itemId: itemObj?.id ?? 0, commentId: commentId)
    }

    func postNotificationToUpdateCommentInBoard() {
        NotificationCenter.default.post(
            name: NSNotification.Name(
                rawValue: NotificationKeys.refreshCommentCountBoard.rawValue
            ),
            object: [
                "count": objVM.totalCommentCount,
                "boardId": itemObj?.id ?? 0,
                "lastComment": (objVM.commentsArray.count > 0 ? objVM.commentsArray.first : nil)
            ],
            userInfo: nil
        )
    }

   
    func scrollToBottom(proxy: ScrollViewProxy) {

        if let last = objVM.commentsArray.first {

            DispatchQueue.main.asyncAfter(deadline:.now()+0.1) {

                proxy.scrollTo(last.id,anchor:.bottom)
            }
        }
    }

    func sendComment() {
        isFocused = false

        if selectedCommentObj != nil {

            if (selectedCommentObj?.parentID ?? 0) > 0 {

                objVM.editReply(
                    commentId: selectedCommentObj?.id ?? 0,
                    comment: commentText,
                    parentId: selectedCommentObj?.parentID ?? 0
                )

            } else {

                objVM.editComment(
                    commentId: selectedCommentObj?.id ?? 0,
                    comment: commentText
                )
            }

        } else if replyCommentId > 0 {

            objVM.replyComment(
                itemId: itemObj?.id ?? 0,
                msg: commentText,
                comment_id: replyCommentId
            )

        } else {

            objVM.addComment(
                msg: commentText,
                itemId: itemObj?.id ?? 0
            )
        }

        commentText = ""
        replyCommentId = 0
        replyingTo = ""
        selectedCommentObj = nil
    }
}



#Preview {
    CommentsView(onClose: {isToProfileOpen,user  in
        
    }, itemObj: nil, navController: nil)
}


struct CommentRow: View {
    
    @Binding var comment: CommentModel
    var onReply: () -> Void
    var onLikeDislike: (_ commentId:Int,_ isliked:Bool) -> Void
    var loadMoreReplies: (_ commentId:Int) -> Void
    var selectedOption:(_ commentObj:CommentModel) -> Void
    var selectedUser:(_ user:User?) -> Void

    
    var body: some View {
        VStack{
            HStack(alignment: .top, spacing: 12) {
//                if let url = URL(string: comment.user?.profile ?? "")
//                {
                    AsyncImage(url:URL(string: comment.user?.profile ?? "")) { img in
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    } placeholder: {
                        Image("user-circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30,height:30)
                            .clipShape(Circle())
                    }.onTapGesture {
                        selectedUser(comment.user)
                    }
                //}
                
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack {
                        Text(comment.user?.name ?? "").autocapitalization(.words)
                            .font(.inter(.medium, size: 16))
                        Text((comment.createdAt ?? "").timeAgoDisplay())
                            .font(.inter(.regular, size: 12))
                            .foregroundColor(.gray)
                        
                        if comment.user?.id == Local.shared.getUserId(){
                            Button {
                                selectedOption(comment)
                            } label: {
                                Image("threeDotHori")
                            }
                        }
                       
                        
                    }
                    
                    Text(comment.comment ?? "")
                        .font(.inter(.regular, size: 14))
                        .foregroundColor(Color(hex: "#6E6E6E"))
                    
                    Button("Reply") {
                        onReply()
                    }
                    .font(.inter(.regular, size: 14))
                    .foregroundColor(Color(.label))
                }
                
                Spacer()
                
                VStack(alignment:.center, spacing: 4) {
                    Button {
                        comment.isLiked?.toggle()
                        comment.likesCount =  (comment.likesCount ?? 0) + ((comment.isLiked ?? false) ? 1 : -1)
                        onLikeDislike(comment.id ?? 0, comment.isLiked ?? false)
                    } label: {
                        Image(systemName: (comment.isLiked ?? false) ? "heart.fill" : "heart")
                            .foregroundColor((comment.isLiked ?? false) ? .orange : .gray)
                    }
                    
                    if (comment.likesCount ?? 0) > 0{
                        Text("\(comment.likesCount ?? 0)")
                            .font(.inter(.medium, size: 12))
                    }
                }
            }
            
            if (comment.repliesCount ?? 0) > 0 {
                
                
                ForEach(comment.replyArray ?? []){ reply in
                    
                    ReplyCommentRow(comment: reply) { commentId, isliked in
                        updatelikeInArrayOfReplies(commentId: commentId, islike: isliked)
                    } selectedOption: { commentObj in
                        selectedOption(commentObj)
                    } selectedUser: {user in
                        selectedUser(user)

                    }.padding(.leading,50)

                   /* ReplyCommentRow(comment: reply) { commentId, islike in
                        
                        updatelikeInArrayOfReplies(commentId: commentId, islike: islike)
                        
                    }.padding(.leading,50)*/
                }
                
                if comment.replyArray?.count != (comment.repliesCount ?? 0){
                    Button {
                        loadMoreReplies(comment.id ?? 0)
                    } label: {
                        Text("View more \(comment.repliesCount ?? 0) replies").font(.inter(.medium, size: 11)).foregroundColor(Color(.label))
                    }.padding(.leading,50)
                    
                }
                
            }
        }
        
    }
    
    func updatelikeInArrayOfReplies(commentId:Int,islike:Bool){
        let index = comment.replyArray?.firstIndex { $0.id == commentId
        }
        comment.replyArray?[index ?? 0].isLiked = islike
        
        if islike{
            comment.replyArray?[index ?? 0].likesCount =  (comment.replyArray?[index ?? 0].likesCount ?? 0) + 1
            
        }else{
            comment.replyArray?[index ?? 0].likesCount =  (comment.replyArray?[index ?? 0].likesCount ?? 0) - 1
        }
    }
}





struct ReplyCommentRow: View {
    
    var comment: CommentModel
    var onLikeDislike: (_ commentId:Int,_ isliked:Bool) -> Void
    var selectedOption:(_ commentObj:CommentModel) -> Void
    var selectedUser:(_ user:User?) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
//            if let url = URL(string: comment.user?.profile ?? "")
//            {
                
                AsyncImage(url: URL(string: comment.user?.profile ?? "")) { img in
                    img.resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } placeholder: {
                    Image("user-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30,height:30)
                        .clipShape(Circle())
                }.onTapGesture {
                    selectedUser(comment.user)
                }
           // }
            
            
            VStack(alignment: .leading, spacing: 2) {
                
                HStack {
                    Text(comment.user?.name ?? "")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text((comment.createdAt ?? "").timeAgoDisplay())
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    if comment.user?.id == Local.shared.getUserId(){
                        
                        Button {
                            selectedOption(comment)
                        } label: {
                            Image("threeDotHori")
                        }
                    }
                }
                
                Text(comment.comment ?? "")
                    .font(.system(size: 14))
                
            }
            
            Spacer()
            
            VStack(alignment:.center, spacing: 4) {
                Button {
                    let isliked = (comment.isLiked ?? false) ? false : true
                    onLikeDislike(comment.id ?? 0, isliked)
                    //comment.isLiked?.toggle()
                    //                    comment.likesCount =  (comment.likesCount ?? 0) + ((comment.isLiked ?? false) ? 1 : -1)
                    //                    onLikeDislike(comment.id ?? 0, comment.isLiked ?? false)
                } label: {
                    Image(systemName: (comment.isLiked ?? false) ? "heart.fill" : "heart")
                        .foregroundColor((comment.isLiked ?? false) ? .orange : .gray)
                }
                if (comment.likesCount ?? 0) > 0{
                    
                    Text("\(comment.likesCount ?? 0)")
                        .font(.system(size: 12))
                }
            }
        }
    }
}


import Combine

class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .assign(to: &$height)
    }
}





struct GrowingTextViewNew: UIViewRepresentable {

    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    @Binding var isFocused: Bool   // ADD THIS

    var minHeight: CGFloat = 35
    var maxLength: Int = 100
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {

        let textView = UITextView()

        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 15)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.showsHorizontalScrollIndicator = false
        textView.alwaysBounceHorizontal = false
        textView.tintColor = .systemOrange

        textView.textContainer.lineBreakMode = .byWordWrapping

        //IMPORTANT
        textView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 12,
            bottom: 8,
            right: 12
        )

        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {

        if uiView.text != text {
            uiView.text = text
        }

        
        //  HANDLE KEYBOARD FOCUS
            if isFocused && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }

            if !isFocused && uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        recalcHeight(view: uiView)
    }

    private func recalcHeight(view: UITextView) {

        let fittingSize = CGSize(
            width: view.frame.width,
            height: .greatestFiniteMagnitude
        )

        let size = view.sizeThatFits(fittingSize)

        let newHeight = max(minHeight, size.height)

        if dynamicHeight != newHeight {
            DispatchQueue.main.async {
                dynamicHeight = newHeight
            }
        }

        //  Prevent leftover scroll offset when deleting text
        if view.text.isEmpty {
            view.setContentOffset(.zero, animated: false)
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {

        var parent: GrowingTextViewNew

        init(_ parent: GrowingTextViewNew) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.recalcHeight(view: textView)
        }

        // 🔥 CHARACTER LIMIT LOGIC
        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText replacement: String
        ) -> Bool {

            guard let currentText = textView.text,
                  let stringRange = Range(range, in: currentText)
            else {
                return false
            }

            let updatedText = currentText.replacingCharacters(
                in: stringRange,
                with: replacement
            )

            return updatedText.count <= parent.maxLength
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }
    }
}


class IntrinsicTextView: UITextView {

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric,
               height: contentSize.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}



import Foundation

extension String {
    
    func timeAgoDisplay() -> String {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        guard let date = formatter.date(from: self) else {
            return ""
        }
        
        let secondsAgo = Int(Date().timeIntervalSince(date))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        let year = 365 * day
        
        switch secondsAgo {
        case 0..<minute:
            return "\(secondsAgo)s"
        case minute..<hour:
            return "\(secondsAgo / minute)m"
        case hour..<day:
            return "\(secondsAgo / hour)h"
        case day..<week:
            return "\(secondsAgo / day)d"
        case week..<month:
            return "\(secondsAgo / week)w"
        case month..<year:
            return "\(secondsAgo / month)mo"
        default:
            return "\(secondsAgo / year)y"
        }
    }
}

extension String {
    func replacingPrefix(_ prefix: String, with newValue: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return newValue + self.dropFirst(prefix.count)
    }
}


