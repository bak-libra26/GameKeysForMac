import SwiftUI
import AppKit

/// 메뉴바 키캡 아이콘 — ON: 초록, OFF: 회색 (캐시됨)
enum MenuBarIcon {
    private static let onImage = renderImage(isActive: true)
    private static let offImage = renderImage(isActive: false)

    static func image(isActive: Bool) -> NSImage {
        isActive ? onImage : offImage
    }

    private static func renderImage(isActive: Bool) -> NSImage {
        let size: CGFloat = 18
        let img = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            let cx = rect.midX
            let cy = rect.midY - 1
            let sx: CGFloat = size * 0.38
            let sy: CGFloat = size * 0.14
            let depth: CGFloat = size * 0.18

            let topColor: NSColor
            let leftColor: NSColor
            let rightColor: NSColor

            if isActive {
                topColor = NSColor(red: 0.29, green: 0.87, blue: 0.50, alpha: 1)
                leftColor = NSColor(red: 0.10, green: 0.62, blue: 0.28, alpha: 1)
                rightColor = NSColor(red: 0.09, green: 0.50, blue: 0.23, alpha: 1)
            } else {
                topColor = NSColor(white: 0.45, alpha: 1)
                leftColor = NSColor(white: 0.33, alpha: 1)
                rightColor = NSColor(white: 0.28, alpha: 1)
            }

            let left = NSBezierPath()
            left.move(to: NSPoint(x: cx - sx, y: cy + sy))
            left.line(to: NSPoint(x: cx, y: cy - sy))
            left.line(to: NSPoint(x: cx, y: cy - sy - depth))
            left.line(to: NSPoint(x: cx - sx, y: cy + sy - depth))
            left.close()
            leftColor.setFill()
            left.fill()

            let right = NSBezierPath()
            right.move(to: NSPoint(x: cx + sx, y: cy + sy))
            right.line(to: NSPoint(x: cx, y: cy - sy))
            right.line(to: NSPoint(x: cx, y: cy - sy - depth))
            right.line(to: NSPoint(x: cx + sx, y: cy + sy - depth))
            right.close()
            rightColor.setFill()
            right.fill()

            let top = NSBezierPath()
            top.move(to: NSPoint(x: cx, y: cy + sy * 2.6))
            top.line(to: NSPoint(x: cx - sx, y: cy + sy))
            top.line(to: NSPoint(x: cx, y: cy - sy))
            top.line(to: NSPoint(x: cx + sx, y: cy + sy))
            top.close()
            topColor.setFill()
            top.fill()

            return true
        }
        img.isTemplate = false
        return img
    }
}
