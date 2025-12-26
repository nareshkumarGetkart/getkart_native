//
//  ReportUser.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/12/25.
//
import SwiftUI
import Combine
  
struct ReportUserView: View {

    @State private var comment = ""
    @State private var textHeight: CGFloat = 44
    @ObservedObject private var kb = KeyboardListener()
    @State private var listArray = [ReportModel]()
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var commentFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedReasonId: Int?
    let roportUserId:Int

    var body: some View {

        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image(systemName: "xmark").foregroundColor(Color(.label))
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }

            Spacer()

            Text("Report user")
                .font(.system(size: 18, weight: .semibold))
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.vertical, 5)
        .background(Color(.systemBackground))
        
        VStack(spacing: 0) {

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {

                    // REASON LIST
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(listArray) { reasons in
                            RadioRow(text: reasons.reason ?? "", isSelected: selectedReasonId  == reasons.id)
                                .onTapGesture { selectedReasonId = reasons.id }
                        }
                    }

                    // MARK: - Comment Section
                    Text("Add a comment")
                        .font(.headline)
                      //  .padding(.top, 10)

                    ZStack(alignment: .topLeading) {

                        // Placeholder
                        if comment.isEmpty {
                            Text("Comment")
                                .foregroundColor(Color.gray)
                                .padding(.leading, 8)
                                .padding(.top, 12)
                        }

                        GeometryReader { geo in
                            GrowingTextEditor(
                                text: $comment,
                                height: $textHeight,
                                maxWidth: geo.size.width,
                                maxHeight: 200
                            )
                            .frame(height: textHeight)
                            
                        }
                        .frame(height: textHeight)
                        
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                }
                .padding(15)
            }

            // MARK: - Send Button
            Button(action: sendReport) {
                Text("Send")
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canSend ? Color.orange : Color.gray.opacity(0.4))
                    .cornerRadius(8)
            }
            .disabled(!canSend)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

        }
        .padding(.bottom, kb.height) // adjusts for keyboard perfectly
        .animation(.easeOut(duration: 0.2), value: kb.height)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if listArray.count == 0{
                getReportReasonsListApi()
            }
        }
    }
    
    // VALIDATION
    private var canSend: Bool {
        selectedReasonId != nil  //|| !comment.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func sendReport() {
        print("Selected reason:", selectedReasonId ?? 0)
        print("Comment:", comment)
        if let reasonId = selectedReasonId{
            reportItemApi(reportedReasonId: reasonId)
        }
    }

    //MARK: Api methods
    func getReportReasonsListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_report_reasons) { (obj:Report) in
            
            if obj.data != nil {
                self.listArray = obj.data?.data ?? []
                }
            
        }
    }
    
    func reportItemApi(reportedReasonId:Int){
        /*
         'user_id'  : 'required|integer',
         'report_reason_id' : 'required_without:other_message',
         'other_message'    : 'required_without:report_reason_id'
         */
        var params = ["report_reason_id":reportedReasonId,"seller_id":roportUserId] as [String : Any]
        
        if comment.trim().count > 0{
            params["other_message"] = comment
        }
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.add_user_reports, param: params,methodType: .post) {  responseObject, error in
            
            
            if(error != nil)
            {
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    AlertView.sharedManager.showToast(message: message)
                   presentationMode.wrappedValue.dismiss()
                   // Pass the offer back
                }
            }
        }
    }
}


class KeyboardListener: ObservableObject {
    @Published var height: CGFloat = 0

    init() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { notif in
            guard let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let screen = UIScreen.main.bounds.height
            if frame.origin.y >= screen {
                self.height = 0
            } else {
                let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                self.height = frame.height - bottom   // <-- FIXED
            }
        }
    }
}

// MARK: - Keyboard Safe Area Helper

struct KeyboardHeight: ViewModifier {
    @State private var height: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, height)
            .animation(.easeOut(duration: 0.25), value: height)
            .onAppear {
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { n in
                    if let h = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        height = h.height - 10
                    }
                }

                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { _ in height = 0 }
            }
    }
}


// MARK: - RADIO ROW

struct RadioRow: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    .frame(width: 22, height: 22)
                
                if isSelected {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 12)
                }
            }
            
            Text(text)
                .font(.system(size: 17))
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}



// MARK: - Preview
struct ReportUserView_Previews: PreviewProvider {
    static var previews: some View {
        ReportUserView(roportUserId: 12)
    }
}


extension View {
    func keyboardSafeArea() -> some View {
        self.modifier(KeyboardHeight())
    }
}


// MARK: - Growing Text Editor

struct GrowingTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat

    var maxWidth: CGFloat
    var maxHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.isScrollEnabled = false
        tv.delegate = context.coordinator
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        tv.textContainer.lineFragmentPadding = 0
        tv.tintColor = .orange
        // PREVENT HORIZONTAL EXPANDING
        tv.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = tv.widthAnchor.constraint(equalToConstant: maxWidth)
        widthConstraint.priority = .required
        widthConstraint.isActive = true

        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            let selected = uiView.selectedRange
            uiView.text = text
            uiView.selectedRange = selected
        }

        recalcHeight(uiView)

        DispatchQueue.main.async {
            uiView.layoutIfNeeded()
            uiView.layoutManager.ensureLayout(for: uiView.textContainer)
            uiView.scrollRangeToVisible(uiView.selectedRange)
        }
    }

    private func recalcHeight(_ view: UITextView) {
        let size = view.sizeThatFits(
            CGSize(width: maxWidth, height: .infinity)
        )
        let newHeight = max(40, min(size.height, maxHeight))
        DispatchQueue.main.async {
            height = newHeight
            view.isScrollEnabled = size.height > maxHeight
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {

        var parent: GrowingTextEditor
        init(_ parent: GrowingTextEditor) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.recalcHeight(textView)

            DispatchQueue.main.async {
                textView.layoutIfNeeded()
                textView.layoutManager.ensureLayout(for: textView.textContainer)
                textView.scrollRangeToVisible(textView.selectedRange)
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            DispatchQueue.main.async {
                textView.layoutIfNeeded()
                textView.layoutManager.ensureLayout(for: textView.textContainer)
                textView.scrollRangeToVisible(textView.selectedRange)
            }
        }
    }
}



/*

// MARK: - MAIN VIEW
struct ReportUserView: View {

    @State private var listArray = [ReportModel]()
    @Environment(\.presentationMode) var presentationMode
    @State private var comment: String = ""
    @FocusState private var commentFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedReasonId: Int?

    let roportUserId:Int
    var body: some View {

        VStack(spacing: 0) {

            //--------------------------
            // HEADER
            //--------------------------
            HStack {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "xmark").foregroundColor(Color(.label))
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }

                Spacer()

                Text("Report user")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            // CONTENT
            ScrollViewReader { reader in
                ScrollView {

                    VStack(alignment: .leading, spacing: 22) {

                        // REASON LIST
                        
                        ForEach(listArray) { reasons in
                            RadioRow(text: reasons.reason ?? "", isSelected: selectedReasonId  == reasons.id)
                                .onTapGesture { selectedReasonId = reasons.id }
                        }

                        // COMMENT SECTION
                        VStack(alignment: .leading, spacing: 6) {

                            Text("Add a comment")
                                .font(.system(size: 16, weight: .semibold))
                            TextEditor(text: $comment).frame(minHeight:50)
                                .onChange(of: comment) { newValue in
                                if newValue.count > 300 {
                                    comment = String(newValue.prefix(300))
                                }
                                }
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.gray, lineWidth: 0.5)
//                                )
//                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black.opacity(0.5))
                        }
                        .padding(.top, 6)

                        Spacer(minLength: 170)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                }
                .onChange(of: commentFocused) { focus in
                    if focus {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation {
                                reader.scrollTo("COMMENT_FIELD", anchor: .bottom)
                            }
                        }
                    }
                }
            }

            // SEND BUTTON
            VStack {
                Button(action: sendReport) {
                    Text("Send")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canSend ? Color.orange : Color.gray.opacity(0.4))
                        .cornerRadius(8)
                }
                .disabled(!canSend)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)

            }
            .padding(.bottom, keyboardHeight)
            .background(Color(.systemBackground))
        }.id("COMMENT_FIELD")
       
        .ignoresSafeArea(.keyboard)
        .onAppear(perform: subscribeToKeyboard)
        .onAppear {
            if listArray.count == 0{
                getReportReasonsListApi()
            }
        }
        
    }

    // VALIDATION
    private var canSend: Bool {
        selectedReasonId != nil  //|| !comment.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func sendReport() {
        print("Selected reason:", selectedReasonId ?? 0)
        print("Comment:", comment)
        if let reasonId = selectedReasonId{
            reportItemApi(reportedReasonId: reasonId)
        }
    }

    //--------------------------
    // KEYBOARD LISTENER
    //--------------------------
    private func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }
    
    //MARK: Api methods
    func getReportReasonsListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_report_reasons) { (obj:Report) in
            
            if obj.data != nil {
                self.listArray = obj.data?.data ?? []
                
//                self.listArray.append(ReportModel(id: 1000, reason: "Other", createdAt: nil, updatedAt: nil))
            }
            
        }
    }
    
    func reportItemApi(reportedReasonId:Int){
        /*
         'user_id'  : 'required|integer',
         'report_reason_id' : 'required_without:other_message',
         'other_message'    : 'required_without:report_reason_id'
         */
        var params = ["report_reason_id":reportedReasonId,"seller_id":roportUserId] as [String : Any]
        
        if comment.trim().count > 0{
            params["other_message"] = comment
        }
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.add_user_reports, param: params,methodType: .post) {  responseObject, error in
            
            
            if(error != nil)
            {
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    AlertView.sharedManager.showToast(message: message)
                   presentationMode.wrappedValue.dismiss()
                   // Pass the offer back
                }
            }
        }
    }
}


 */


