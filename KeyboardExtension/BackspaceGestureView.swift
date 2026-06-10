import SwiftUI

struct BackspaceKey: View {
    @Binding var slideCount: Int
    var cornerRadius: CGFloat = 5
    var iconSize: CGFloat = 18
    let onTap: () -> Void
    let onSlideDelete: (Int) -> Void

    @State private var isSlideMode = false
    @State private var internalCount = 0
    @State private var repeatTimer: Timer?
    @State private var repeatCount = 0
    private let pixelsPerChar: CGFloat = 13
    // この距離を超えて動いたら連続削除をやめてスライド削除モードに切り替える
    private let slideActivation: CGFloat = 12

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(slideCount > 0 ? Color.red.opacity(0.15) : Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
            Image(systemName: "delete.left")
                .font(.system(size: iconSize))
                .foregroundColor(slideCount > 0 ? .red : Color(UIColor.label))
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            // 0.3s長押しでスライドモードに入る。maximumDistance:100で指がずれてもOK
            LongPressGesture(minimumDuration: 0.3, maximumDistance: 100)
                .onEnded { _ in
                    isSlideMode = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    startRepeat()
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    guard isSlideMode else { return }
                    // 指を動かしたら連続削除を止めてスライド削除に切り替え
                    if abs(value.translation.width) > slideActivation {
                        stopRepeat()
                    }
                    let count = max(0, Int(-value.translation.width / pixelsPerChar))
                    internalCount = count
                    withAnimation(.easeInOut(duration: 0.1)) { slideCount = count }
                }
                .onEnded { _ in
                    stopRepeat()
                    if isSlideMode {
                        if internalCount > 0 { onSlideDelete(internalCount) }
                        withAnimation(.easeOut(duration: 0.1)) { slideCount = 0 }
                        internalCount = 0
                    } else {
                        onTap()
                    }
                    isSlideMode = false
                }
        )
    }

    // MARK: - 長押し連続削除（だんだん加速）

    private func startRepeat() {
        repeatCount = 0
        // 初回は少し待つ: スライド削除したい人の指が動き出すまでの猶予
        scheduleNextRepeat(after: 0.45)
    }

    private func scheduleNextRepeat(after interval: TimeInterval) {
        repeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            onTap()
            repeatCount += 1
            let next = max(0.05, 0.15 * pow(0.90, Double(repeatCount)))
            scheduleNextRepeat(after: next)
        }
    }

    private func stopRepeat() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }
}
