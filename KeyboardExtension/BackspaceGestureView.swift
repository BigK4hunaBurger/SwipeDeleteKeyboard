import UIKit
import SwiftUI

// UIKit view that handles long-press + slide-left to batch delete
final class BackspaceGestureView: UIView {
    var onTap: (() -> Void)?
    var onSlideDelete: ((Int) -> Void)?
    var onCountChange: ((Int) -> Void)? // 0 = not in slide mode

    private var longPressTimer: Timer?
    private var isSlideMode = false
    private var touchStartX: CGFloat = 0
    private var pendingCount = 0

    // pixels of slide per character
    private let pixelsPerChar: CGFloat = 13

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchStartX = touch.location(in: window ?? self).x
        isSlideMode = false
        pendingCount = 0

        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.enterSlideMode()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isSlideMode else { return }
        let x = touch.location(in: window ?? self).x
        let distance = touchStartX - x
        pendingCount = max(0, Int(distance / pixelsPerChar))
        onCountChange?(pendingCount)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        longPressTimer = nil

        if isSlideMode {
            onCountChange?(0)
            if pendingCount > 0 {
                onSlideDelete?(pendingCount)
            }
        } else {
            onTap?()
        }
        isSlideMode = false
        pendingCount = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        longPressTimer = nil
        isSlideMode = false
        pendingCount = 0
        onCountChange?(0)
    }

    private func enterSlideMode() {
        isSlideMode = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onCountChange?(0)
    }
}

// SwiftUI wrapper
struct BackspaceButton: UIViewRepresentable {
    let onTap: () -> Void
    let onSlideDelete: (Int) -> Void
    let onCountChange: (Int) -> Void

    func makeUIView(context: Context) -> BackspaceGestureView {
        let v = BackspaceGestureView()
        v.backgroundColor = .clear
        v.onTap = onTap
        v.onSlideDelete = onSlideDelete
        v.onCountChange = onCountChange
        return v
    }

    func updateUIView(_ uiView: BackspaceGestureView, context: Context) {
        uiView.onTap = onTap
        uiView.onSlideDelete = onSlideDelete
        uiView.onCountChange = onCountChange
    }
}
