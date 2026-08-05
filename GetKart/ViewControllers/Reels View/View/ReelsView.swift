import SwiftUI
import AVFoundation

struct ReelsView: View {
    
    let navigationController: UINavigationController?
      let itemObj: ItemModel?

      @StateObject private var viewModel: ReelsViewModel
    @State private var presentedURL: URL?   // NEW — lives here, never recreated by VerticalPager

      init(navigationController: UINavigationController?, itemObj: ItemModel?) {
          self.navigationController = navigationController
          self.itemObj = itemObj

          let vm = ReelsViewModel()

          if let itemObj {
              vm.reels.append(itemObj)
          }

          _viewModel = StateObject(wrappedValue: vm)
      }
    
    var body: some View {
        GeometryReader { geo in   // ONE GeometryReader for the whole feed, not per-page
            
            ZStack {
                
                Color.black.ignoresSafeArea()
                
                if viewModel.reels.isEmpty {
                    
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("No reels found").foregroundColor(.white)
                    }
                    
                } else {
                    
                    VerticalPager(
                        index: $viewModel.currentIndex,
                        count: viewModel.reels.count
                    ) { index in
                        ReelPageView(
                            item: viewModel.reels[index],
                            isCurrent: index == viewModel.currentIndex,
                            viewModel: viewModel,
                            safeAreaTop: geo.safeAreaInsets.top,
                            safeAreaBottom: geo.safeAreaInsets.bottom,
                            onBack: {
                                ReelsVideoManager.shared.pauseAll()
                                navigationController?.popViewController(animated: true)
                            },
                            onOpenLink: { url in       // NEW
                                ReelsVideoManager.shared.pauseAll()
                                presentedURL = url
                            }
                        )
                    }
                }
                
                if viewModel.isLoading && !viewModel.reels.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView().tint(.white).padding(.bottom, 30)
                    }
                }
            }.ignoresSafeArea()
                .navigationBarHidden(true)
                .statusBar(hidden: false)
                .task {
                    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
                    try? AVAudioSession.sharedInstance().setActive(true)
                    viewModel.loadOnce() //loadIfNeeded()
                }
                .onChange(of: viewModel.currentIndex) { index in
                    viewModel.reelAppeared(at: index)
                }
                .onDisappear {
                    ReelsVideoManager.shared.pauseAll()
                }.onAppear{
                  //  ReelsVideoManager.shared.resumeCurrent()
                }
                .fullScreenCover(item: $presentedURL) { url in
                    SafariView(url: url)
                        .onDisappear {
                            presentedURL = nil
                            ReelsVideoManager.shared.resumeCurrent()   // now has a valid id to resume
                            if let idss = viewModel.reels[viewModel.currentIndex].id{
                                ReelsVideoManager.shared.playOnly(id: idss)
                            }
                        }
                }
        }
    }
}
