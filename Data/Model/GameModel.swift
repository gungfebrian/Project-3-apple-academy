import Foundation
import CoreGraphics

// MARK: - Falling Word

struct FallingWord: Identifiable {
    let id = UUID()
    let text: String
    var x: CGFloat
    var y: CGFloat
    let vy: CGFloat
    let rotation: Double
    let chipTone: ChipTone
}

// MARK: - Word Popper (catch feedback overlay)

struct WordPopper: Identifiable {
    let id = UUID()
    let text: String
    let isP2: Bool       // VS mode: true = caught by player 2
    var yOffset: CGFloat = 0
    var opacity: Double = 1
}
