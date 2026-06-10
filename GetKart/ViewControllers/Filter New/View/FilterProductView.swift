//
//  FilterProductView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/06/26.
//

import SwiftUI


struct FilterProductView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = FilterProductViewModal()

    var body: some View {

        VStack(spacing: 0) {

            headerView

            Divider()

            contentView

            Divider()

            bottomView
        }
        .background(Color.white)
        .clipShape(
            RoundedCorner(radius: 28,
                          corners: [.topLeft, .topRight])
        )
        .ignoresSafeArea(edges: .bottom)
    }
}
extension FilterProductView {

    var headerView: some View {

        HStack {

            Text("FILTER")
                .font(.system(size: 18, weight: .bold))

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}

extension FilterProductView {

    var contentView: some View {

        HStack(spacing: 0) {

            leftMenu

            Divider()

            rightOptions
        }
    }
}

extension FilterProductView {

    var leftMenu: some View {

        VStack(alignment: .leading, spacing: 0) {

            ForEach(Array(vm.categories.enumerated()),
                    id: \.offset) { index, category in

                Button {

                    vm.selectedCategory = index

                } label: {

                    HStack {

                        VStack(alignment: .leading,
                               spacing: 4) {

                            Text(category.title)
                                .font(.system(size: 17,
                                              weight: .semibold))
                                .foregroundColor(
                                    vm.selectedCategory == index
                                    ? .orange
                                    : .black
                                )
                        }

                        Spacer()

                        if let count = category.count {

                            Text(count)
                                .foregroundColor(.orange)
                                .font(.system(size: 15,
                                              weight: .medium))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        vm.selectedCategory == index
                        ? Color.white
                        : Color.gray.opacity(0.08)
                    )
                }
            }

            Spacer()
        }
        .frame(width: 150)
        .background(Color.gray.opacity(0.08))
    }
}

extension FilterProductView {

    var rightOptions: some View {

        VStack(alignment: .leading,
               spacing: 16) {

            Text("FILTER BY PRICE")
                .font(.headline)

            Text("Choose from options below")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView {

                VStack(spacing: 16) {

                    ForEach(vm.priceOptions) { option in

                        FilterOptionRow(
                            option: option,
                            isSelected: vm.selectedOption == option.title
                        ) {

                            vm.selectedOption = option.title
                        }
                    }
                }
                .padding(.top)
            }
        }
        .padding()
    }
}
extension FilterProductView {

    var bottomView: some View {

        HStack {

            Button {

                vm.selectedOption = nil

            } label: {

                Text("Clear Filters")
                    .font(.system(size: 18,
                                  weight: .bold))
                    .foregroundColor(.orange)
                    .frame(height: 50)
            }

            Spacer()

            Button {

                // Apply Filter

            } label: {

                Text("Apply")
                    .font(.system(size: 22,
                                  weight: .bold))
                    .foregroundColor(.white)
                    .frame(width:200,height: 50)
                    .background(Color.orange)
                    .cornerRadius(14)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}
#Preview {
    FilterProductView()
}

//struct RoundedCorner: Shape {
//
//    var radius: CGFloat = 20
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corners,
//            cornerRadii: CGSize(width: radius,
//                                height: radius)
//        )
//
//        return Path(path.cgPath)
//    }
//}

struct FilterOptionRow: View {

    let option: FilterOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack {

                Text(option.title)
                    .font(.system(size: 17,
                                  weight: .medium))

                Spacer()

                Text(option.itemCount)
                    .font(.system(size: 15,
                                  weight: .semibold))
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                        ? Color.orange
                        : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(12)
        }
        .foregroundColor(.black)
    }
}
