//
//  ShimmerModifier.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/04/26.
//

import SwiftUI

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.3),
                            Color.gray.opacity(0.1),
                            Color.gray.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 2, height: geo.size.height * 2)
                    .offset(x: geo.size.width * phase)
                    .onAppear {
                        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
                }
            )
            .mask(content)
    }
}

import SwiftUI

struct ShimmerEffect: ViewModifier {

    @State private var moveToRight: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.25),
                                    Color.white.opacity(0.6),
                                    Color.gray.opacity(0.25)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(20))
                        .offset(x: moveToRight ? geo.size.width * 2 : -geo.size.width * 2)
                        .animation(
                            .linear(duration: 1.0)
                            .repeatForever(autoreverses: false),
                            value: moveToRight
                        )
                        .onAppear {
                            moveToRight = true
                        }
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}

struct SkeletonCardView: View {
    var height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.gray.opacity(0.25))
            .frame(height: height)
            .shimmer()
    }
}

struct PinterestSkeletonGrid: View {

    let heightsLeft: [CGFloat] = [180, 260, 210, 300, 190, 240]
    let heightsRight: [CGFloat] = [250, 180, 320, 200, 270, 220]

    var body: some View {
        HStack(alignment: .top, spacing: 6) {

            LazyVStack(spacing: 6) {
                ForEach(0..<heightsLeft.count, id: \.self) { i in
                    SkeletonCardView(height: heightsLeft[i])
                }
            }

            LazyVStack(spacing: 6) {
                ForEach(0..<heightsRight.count, id: \.self) { i in
                    SkeletonCardView(height: heightsRight[i])
                }
            }
        }
        .padding(.horizontal, 5)
    }
}
