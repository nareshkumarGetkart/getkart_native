import SwiftUI
import AVKit

struct ReelProgressView: View {

    let player: AVQueuePlayer?
    let isMuted: Bool          // was: @Binding var isMuted: Bool
    let onToggleMute: () -> Void
    
//    let player: AVQueuePlayer?
//    @Binding var isMuted: Bool
//    let onToggleMute: () -> Void

    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isDragging = false
    @State private var dragValue: Double = 0

    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 8) {

            Text(timeString(currentTime))
                .font(.caption2.monospacedDigit())
                .foregroundColor(.white)

            Slider(
                value: Binding(
                    get: { isDragging ? dragValue : currentTime },
                    set: { dragValue = $0; isDragging = true }
                ),
                in: 0...(max(duration, 0.1)),
                onEditingChanged: { editing in
                    if !editing {
                        seek(to: dragValue)
                        isDragging = false
                    }
                }
            )
            .tint(.white)

            Text(timeString(duration))
                .font(.caption2.monospacedDigit())
                .foregroundColor(.white)

            Button(action: onToggleMute) {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
        .onReceive(timer) { _ in

            guard let player, !isDragging else { return }

            let t = player.currentTime().seconds
            currentTime = t.isFinite ? t : 0

            if let d = player.currentItem?.duration.seconds, d.isFinite {
                duration = d
            }
        }
    }

    private func seek(to seconds: Double) {

        guard let player else { return }

        player.seek(
            to: CMTime(seconds: seconds, preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    private func timeString(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "00:00" }
        return String(format: "%02d:%02d", Int(seconds) / 60, Int(seconds) % 60)
    }
}
