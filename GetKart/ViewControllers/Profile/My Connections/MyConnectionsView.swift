//
//  MyConnectionsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/05/26.
//

//
//  MyConnectionsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/05/26.
//

import SwiftUI

enum ConnectionsTab: Int, CaseIterable {
    case followings = 0
    case followers  = 1

    var title: String {
        switch self {
        case .followers:  return "Followers"
        case .followings: return "Follow"       // matches your screenshot label
        }
    }
}

struct MyConnectionsView: View {
    var navigation: UINavigationController?

    @State private var selectedTab: ConnectionsTab = .followings

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ────────────────────────────────────────────────
            HStack {
                Button {
                    navigation?.popViewController(animated: true)
                } label: {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }
                .frame(width: 40, height: 40)

                Text("My Connections")
                    .font(.custom("Manrope-Bold", size: 18))
                    .foregroundColor(Color(UIColor.label))

                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 8)
            .background(Color(UIColor.systemBackground))

            // ── Tab bar ───────────────────────────────────────────────
            tabBar
                .padding(.bottom, 0)

            Divider()

            // ── Paged content ─────────────────────────────────────────
            // TabView selection is driven by the raw Int value of the enum,
            // so each child must carry a matching .tag(_:).
            TabView(selection: $selectedTab) {

                // "Follow" tab  (followings)
                FollowerListView(
                    navController: navigation,
                    isFollower: false,
                    userId: Local.shared.getUserId(),
                    showHeader: false
                )
                // ▼ critical – must match enum raw value
                .tag(ConnectionsTab.followings)

                // "Followers" tab
                FollowerListView(
                    navController: navigation,
                    isFollower: true,
                    userId: Local.shared.getUserId(),
                    showHeader: false
                )
                .tag(ConnectionsTab.followers)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            // Disable the bounce-back colour that shows the grouped background
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemBackground))
        // Hide the navigation bar injected by FollowerListView
        .navigationBarHidden(true)
    }
}

// ── Tab bar ────────────────────────────────────────────────────────────────────
extension MyConnectionsView {

    var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ConnectionsTab.allCases, id: \.self) { tab in
                VStack(spacing: 8) {
                    Text(tab.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(UIColor.label))

                    Rectangle()
                        .fill(selectedTab == tab ? Color.orange : Color.clear)
                        .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    MyConnectionsView()
}
