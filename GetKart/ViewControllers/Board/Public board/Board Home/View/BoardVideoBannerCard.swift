//
//  BoardVideoBannerCard.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/07/26.
//

import SwiftUI
import AVFoundation

struct BoardVideoBannerCard: View {

    let product: ItemModel

    let onClickedView: (URL) -> Void

    @StateObject
    private var video = BannerVideoPlayer()

    @State
    private var isMuted = true

    var body: some View {

        VStack(spacing: 0) {

            ZStack(alignment: .topTrailing) {

                PlayerLayerView(player: video.player)
                    .frame(height: 210)
                    .clipped()

                Button {

                    isMuted.toggle()

                    video.mute(isMuted)

                } label: {

                    Image(systemName: isMuted ?
                          "speaker.slash.fill" :
                          "speaker.wave.2.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.black.opacity(0.55))
                        .clipShape(Circle())
                }
                .padding()
            }

            learnMoreBar
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
        .task {

            guard
                let url = URL(string: product.banner?.image ?? "")
            else {
                return
            }

            video.load(url: url)

            video.play()
        }
        .onDisappear {

            video.pause()

            video.mute(true)

            isMuted = true
        }
    }

    private var learnMoreBar: some View {

        HStack {

            Text("Learn more")

            Spacer()

            Image(systemName: "arrow.up.right")
        }
        .padding(.horizontal)
        .frame(height: 36)
        .background(Color(.systemBackground))
        .onTapGesture {
            isMuted = true
            video.mute(true)
            recordOutboundClick()
        }
    }
    
    // MARK: - Analytics / Navigation
    
    private func recordOutboundClick() {
        let banner = product.banner
                        
        if let raw = banner?.thirdPartyLink ?? banner?.url,
           let url = URL(string: raw.getValidUrl()) {
            onClickedView(url)
        }
        if banner?.isCampaign == true {
            campaignClickEventApi(campaignBannerId: banner?.campaignID ?? 0)
        } else {
            captureSliderClickApi(campaignBannerId: banner?.campaignID ?? 0)
        }
    }
    
    private func campaignClickEventApi(campaignBannerId: Int) {
        let params: [String: Any] = [
            "campaign_banner_id": campaignBannerId,
            "event_type": "click",
            "referrer_url": "HOME"
        ]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.campaign_event,
            param: params,
            methodType: .post,
            showLoader: false
        ) { _, _ in }
    }
    
    private func captureSliderClickApi(campaignBannerId: Int) {
        let params: [String: Any] = ["id": campaignBannerId]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.capture_slider_click,
            param: params,
            methodType: .post,
            showLoader: false
        ) { _, _ in }
    }
}



//#Preview {
//    BoardVideoBannerCard()
//}
