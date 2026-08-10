

import SwiftUI
import AVKit

struct ReelPageView: View {
    
    let item: ItemModel
    let isCurrent: Bool
    @ObservedObject var viewModel: ReelsViewModel
    let safeAreaTop: CGFloat        // NEW
    let safeAreaBottom: CGFloat     // NEW
    let onBack: () -> Void
    let onOpenLink: (URL) -> Void   // NEW — replaces local safariURL/fullScreenCover
    let openProfile: (Int) -> Void
    @ObservedObject private var videoManager = ReelsVideoManager.shared   // NEW
    @State private var player: AVQueuePlayer?
    @State private var isPlaying = true
    @State private var showHeart = false
    private var isMuted: Bool { !videoManager.isSoundOn }   // NEW
    
   
    var body: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            videoView
            
            LinearGradient(
                colors: [.black.opacity(0.35), .clear, .clear, .black.opacity(0.75)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
           /* if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 90))
                    .foregroundColor(.white)
                    .scaleEffect(showHeart ? 1 : 0.4)
                    .transition(.scale)
            }*/
            
            VStack {
                topBar
                    .padding(.top, safeAreaTop + 8)
                Spacer()
                bottomOverlay
                    .padding(.bottom, safeAreaBottom + 8)
            }
        } .ignoresSafeArea()   // NEW — apply once at the top level
            .contentShape(Rectangle())
            .onTapGesture { togglePlayPause() }
           /* .onTapGesture(count: 2) {
                likeAnimation()
                if let id = item.id {
                    viewModel.updateLike(boardId: id, isLiked: !(item.isLiked ?? false))
                }
            }*/
        
        
            .onAppear {
                preparePlayer()
                if isCurrent {
                    playThisReel()
                }
            }
            .onDisappear {
                if let id = item.id {
                    ReelsVideoManager.shared.pause(id: id)
                }
            }
            .onChange(of: isCurrent) { nowCurrent in
                print("🔄 isCurrent changed to \(nowCurrent) for id:", item.id ?? -1)
                if nowCurrent {
                    playThisReel()
                } else {
                    if let id = item.id {
                        ReelsVideoManager.shared.pause(id: id)
                    }
                }
            }
        
            
    }
}

// MARK: Top bar
private extension ReelPageView {
    var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.35))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal)
        //.padding(.top, 8)
    }
}

// MARK: Bottom overlay
private extension ReelPageView {
    var bottomOverlay: some View {
        VStack(spacing: 10) {

            //ReelProgressView(player: player, isMuted: $isMuted, onToggleMute: toggleMute)
            HStack(spacing:0){
                // Profile BUTTON
                Button {

                    openProfile(item.user?.id ?? 0)
                } label: {
                    
                    ContactImageSwiftUIView(
                        name: item.user?.name ?? "",
                        imageUrl: item.user?.profile ?? "",
                        fallbackImageName: "user-circle",
                        imgWidth: 32,
                        imgHeight: 32,
                        fontsize:18
                    )
                    
                    
                    .clipShape(Circle())
                }
                ReelProgressView(
                    player: player,
                    isMuted: isMuted,              // now a plain Bool, not a Binding
                    onToggleMute: toggleMute
                )
            }
            VStack(spacing: 12) {

                Text(item.name ?? "")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let title = item.ctaLabel, !title.isEmpty {
                    Button {
                        openCTA()
                    } label: {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.93, green: 0.6, blue: 0.2))
                            .cornerRadius(10)
                    }

                }
            }
            .padding(16)
            .background(.black.opacity(0.35))
            .cornerRadius(20)
        }
        .padding(.horizontal)
        //.padding(.bottom, 10)
      
    }
}

// MARK: Video
private extension ReelPageView {
    var videoView: some View {
        Group {
            if let player {
                PlayerLayerView(player: player).ignoresSafeArea()
            } else {
                ProgressView().tint(.white)
            }
        }
    }
}

// MARK: Player
private extension ReelPageView {

    /// Creates/attaches the player for this reel, but does NOT play it.
    /// Called on mount for all 3 loaded pages (prev/current/next).
    func preparePlayer() {
        guard let id = item.id, let video = item.videoLink, let url = URL(string: video) else { return }
        player = ReelsVideoManager.shared.player(for: id, url: url)
    }

    /// Actually starts playback — only called when this page is the
    /// genuinely visible/current one.
    func playThisReel() {
        guard let id = item.id, let video = item.videoLink, let url = URL(string: video) else { return }
        if player == nil {
            player = ReelsVideoManager.shared.player(for: id, url: url)
        }
        ReelsVideoManager.shared.playOnly(id: id)
        isPlaying = true
    }

    func togglePlayPause() {
        guard let player else { return }
        isPlaying ? player.pause() : player.play()
        isPlaying.toggle()
    }

//    func toggleMute() {
//        guard let id = item.id else { return }
//        ReelsVideoManager.shared.toggleSound(id: id)
//        isMuted.toggle()
//    }

    func toggleMute() {
        ReelsVideoManager.shared.toggleGlobalSound()
    }
   
    func openCTA() {
          guard let link = item.outbondUrl, let url = URL(string: link.getValidUrl()) else {
                print("❌ openCTA: outbondUrl missing/invalid:", item.outbondUrl ?? "nil")
                return
            }
            onOpenLink(url)   // NEW — hand off to ReelsView, no local state involved
        
           viewModel.outboundClickApi(boardId: item.id ?? 0)

        }

    
    func likeAnimation() {
        withAnimation(.spring()) { showHeart = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation { showHeart = false }
        }
    }
}
