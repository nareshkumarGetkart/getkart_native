//
//  LeftAlignedView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/08/25.
//

import SwiftUI

/*

struct LeftAlignedView: View {

    var body: some View {
        RecentSearchesView()

    }
}

#Preview {
    LeftAlignedView()
}




import SwiftUI

struct RecentSearchesView: View {
    let recentSearches = ["Hi", "kia carens", "playstation 3", "cars mahindra"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    // Clear action
                }
                .foregroundColor(.blue)
                .font(.system(size: 14, weight: .semibold))
            }
            
            FlexibleView(data: recentSearches, spacing: 8, alignment: .leading) { item in
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(item)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.4))
                )
            }
        }
        .padding()
    }
}

// Flexible layout for wrapping tags
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
                ForEach(Array(data), id: \.self) { item in
                    content(item)
                        .padding(.all, 4)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geometry.size.width {
                                width = 0
                                height -= d.height + spacing
                            }
                            let result = width
                            if item == data.last {
                                width = 0
                            } else {
                                width -= d.width + spacing
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if item == data.last {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
        .frame(height: calculateHeight(for: data, in: UIScreen.main.bounds.width, spacing: spacing))
    }
    
    private func calculateHeight(for data: Data, in totalWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for item in data {
            let size = CGSize(width: 80, height: 32) // Approx size of tag (better if calculated dynamically)
            if width + size.width > totalWidth {
                width = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            width += size.width + spacing
        }
        return height + rowHeight
    }
}

*/
