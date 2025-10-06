//
//  ContactImageView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/10/25.
//

import UIKit
import Kingfisher


@IBDesignable
class ContactImageView: UIImageView {
    
    private let placeholderLabel = UILabel()
    
    @IBInspectable var placeholderBackground: UIColor = .systemOrange {
        didSet { placeholderLabel.backgroundColor = placeholderBackground }
    }
    
    /// Local fallback image (must exist in Assets.xcassets)
    @IBInspectable var fallbackImageName: String = "user-circle"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
        contentMode = .scaleAspectFill
        
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .white
        placeholderLabel.font = UIFont.Manrope.semiBold(size: 27.0).font
        placeholderLabel.clipsToBounds = true
        placeholderLabel.backgroundColor = placeholderBackground
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2   // Circular
        placeholderLabel.layer.cornerRadius = bounds.width / 2
    }
    
    func configure(name: String?, imageUrl: String?,fontSize:CGFloat = 27.0) {
        
        if (fontSize != 0) {
            placeholderLabel.font = UIFont.Manrope.semiBold(size: fontSize).font
        }
        
        if let urlStr = imageUrl, let url = URL(string: urlStr), !urlStr.isEmpty {
            // Case 1: Load async image
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = img
                        self.placeholderLabel.isHidden = true
                    }
                } else {
                    self.showPlaceholder(name: name)
                }
            }
        } else {
            // Case 2 or 3
            showPlaceholder(name: name)
        }
    }
    
    private func showPlaceholder(name: String?) {
        DispatchQueue.main.async {
            if let name = name, !name.isEmpty, name.lowercased() != "guest user" {
                // Case 2: initials
                self.image = nil
                self.placeholderLabel.isHidden = false
                self.placeholderLabel.text = String(name.prefix(1)).uppercased()
            } else {
                // Case 3: local placeholder image
                self.placeholderLabel.isHidden = true
                self.image = UIImage(named: self.fallbackImageName)
            }
        }
    }
}





import SwiftUI


struct ContactImageSwiftUIView: View {
    var name: String?
    var imageUrl: String?
    var fallbackImageName: String = "user-circle"  // local asset
    var imgWidth: CGFloat = 60
    var imgHeight: CGFloat = 60
    var selectedImage: UIImage? = nil   // 👈 picked image
    
    var body: some View {
        ZStack {
            if let uiImage = selectedImage {
                // ✅ Case 0: user picked an image
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                
            } else if let urlStr = imageUrl, let url = URL(string: urlStr), !urlStr.isEmpty {
                // ✅ Case 1: Load image from URL
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        // Failed → fallback to initials/local
                        placeholderView
                    } else {
                        ProgressView()
                    }
                }
                
            } else {
                // ✅ Case 2 or 3: initials or local
                placeholderView
            }
        }
        .frame(width: imgWidth, height: imgHeight)
        .clipShape(Circle())
    }
    
    
    
    // MARK: - Placeholder View
    @ViewBuilder
    private var placeholderView: some View {
        if let name = name, !name.isEmpty , name.lowercased() != "guest user" {
            // Case 2: initials
            Text(initials(from: name))
                .font(.manrope(.semiBold, size: 27.0))
                .foregroundColor(.white)
                .frame(width: imgWidth, height: imgHeight)
                .background(Color(.systemOrange))
                .clipShape(Circle())
        } else {
            // Case 3: local image
            Image(fallbackImageName)
                .resizable()
                .scaledToFill()
                .frame(width: imgWidth, height: imgHeight)
                .clipShape(Circle())
        }
    }
    
    private func initials(from name: String?) -> String {
        guard let name = name, !name.isEmpty else { return "?" }
        return String(name.prefix(1)).uppercased()
    }
}

/*
 VStack(spacing: 20) {
     ContactImageView(name: "Radheshyam", imageUrl: nil)
     // ✅ shows "R"
     
     ContactImageView(name: nil, imageUrl: "https://picsum.photos/200")
     // ✅ shows image from URL
     
     ContactImageView(name: nil, imageUrl: nil)
     // ✅ shows local placeholder image ("user_placeholder")
 }

 */
