//
//  ConfirmationView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/03/26.


import SwiftUI


//enum ConfirmationType{
//    
//    case deleteComment
//    case blockUser
//    
//}

enum ConfirmationType: Identifiable {
    case deleteComment
    case blockUser
    
    var id: Int {
        switch self {
        case .deleteComment: return 1
        case .blockUser: return 2
        }
    }
}

struct ConfirmationView: View {
  
    var user:User?
    var confirmType:ConfirmationType = .blockUser
    var onCancel: (() -> Void)?
    var onDone: (() -> Void)?
    
    var title: String {
        switch confirmType {
        case .deleteComment:
            return "Are you sure?"
        case .blockUser:
            return "Block \(user?.name?.capitalized ?? "")"
        }
    }

    var subtitle: String {
        switch confirmType {
        case .deleteComment:
            return "This comment will be deleted"
        case .blockUser:
            return "You can’t see, follow, or contact each other. They won’t be notified if you block them."
        }
    }

    var rightButtonTitle: String {
        switch confirmType {
        case .deleteComment:
            return "Delete"
        case .blockUser:
            return "Block"
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text(title)
                .font(.inter(.semiBold, size: 26))
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(.inter(.medium, size: 16))
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                
                Button(action: {
                    onCancel?()
                }) {
                    Text("Cancel")
                        .font(.inter(.medium, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.25))
                        .foregroundColor(.gray)
                        .cornerRadius(25)
                }
                
                Button(action: {
                    onDone?()
                }) {
                    Text(rightButtonTitle)
                        .font(.inter(.medium, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
            .padding(.top, 10)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
        )
        .padding(.horizontal, 10)
    }
    
    func getTitleString() -> String {
        if confirmType == .deleteComment{
            
            return "Are you sure?"
        }else  if confirmType == .blockUser{
            return "Block \(user?.name?.capitalized ?? "")"
        }
        return ""
    }
    
    func getSubTitleString() -> String {
        if confirmType == .deleteComment{
            
            return "This comment will be deleted"
        }else  if confirmType == .blockUser{
            return "You can’t see, follow, or contact each other. They won’t be notified if you block them."
        }
        return ""
    }
    
    
    func getRightButtonTitle() -> String {
        if confirmType == .deleteComment{
            
            return "Delete"
        }else  if confirmType == .blockUser{
            return "Block"
        }
        return ""
    }
}

//#Preview {
//    ConfirmationView(user: User(id: 33925, name: "", email: "", mobile: "", profile: "", createdAt: "", isVerified: 0, showPersonalDetails: 0, countryCode: "", reviewsCount: 0, averageRating: 0, mobileVisibility: 0))
//}


