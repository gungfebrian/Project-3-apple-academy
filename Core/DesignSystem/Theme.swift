import SwiftUI

// MARK: - Color Palette

extension Color {
    static let sunnyBg     = Color(hex: "FFF6E0")
    static let sunnyYellow = Color(hex: "FFD84D")
    static let sunnyCoral  = Color(hex: "FF7A5A")
    static let sunnyTeal   = Color(hex: "2EB8A6")
    static let sunnyInk    = Color(hex: "1C1A15")
    static let sunnyInk2   = Color(hex: "5A554A")
    static let sunnyInk3   = Color(hex: "968F7F")
    static let sunnyRule   = Color(hex: "EADFB9")
    static let sunnyGreen  = Color(hex: "4FB46A")
    static let sunnyPaper  = Color(hex: "FFFDF4")
    static let sunnyLemon  = Color(hex: "FFE680")
    static let sunnyYel2   = Color(hex: "FFC91F")
}

// MARK: - Button Tone

enum ButtonTone {
    case ink, yellow, coral, ghost

    var bg: Color {
        switch self {
        case .ink:    return .sunnyInk
        case .yellow: return .sunnyYellow
        case .coral:  return .sunnyCoral
        case .ghost:  return .sunnyPaper
        }
    }
    var fg: Color {
        switch self {
        case .ink:    return .sunnyBg
        case .yellow: return .sunnyInk
        case .coral:  return .white
        case .ghost:  return .sunnyInk
        }
    }
    var shadow: Color {
        switch self {
        case .ink:    return .black
        case .yellow: return Color(hex: "C9A41A")
        case .coral:  return Color(hex: "C84A2E")
        case .ghost:  return Color(hex: "D6C77E")
        }
    }
}

// MARK: - Card Tone

enum CardTone {
    case cream, yellow, coral, teal, ink

    var bg: Color {
        switch self {
        case .cream:  return Color(hex: "FFFDF4")
        case .yellow: return Color(hex: "FFE680")
        case .coral:  return Color(hex: "FFCFC1")
        case .teal:   return Color(hex: "BBE9E1")
        case .ink:    return Color(hex: "1F1B16")
        }
    }
    var border: Color {
        switch self {
        case .cream:  return Color(hex: "EADFB9")
        case .yellow: return Color(hex: "F0C824")
        case .coral:  return Color(hex: "F0997D")
        case .teal:   return Color(hex: "7BCDBE")
        case .ink:    return Color(hex: "1F1B16")
        }
    }
    var shadow: Color {
        switch self {
        case .cream:  return Color(hex: "A8985F")
        case .yellow: return Color(hex: "C9A41A")
        case .coral:  return Color(hex: "C84A2E")
        case .teal:   return Color(hex: "3F9789")
        case .ink:    return .black
        }
    }
}

// MARK: - Chip Tone

enum ChipTone: CaseIterable {
    case yellow, coral, teal, cream

    var bg: Color {
        switch self {
        case .yellow: return Color(hex: "FFE680")
        case .coral:  return Color(hex: "FFCFC1")
        case .teal:   return Color(hex: "BBE9E1")
        case .cream:  return Color(hex: "FFFDF4")
        }
    }
    var border: Color {
        switch self {
        case .yellow: return Color(hex: "F0C824")
        case .coral:  return Color(hex: "F0997D")
        case .teal:   return Color(hex: "7BCDBE")
        case .cream:  return Color(hex: "EADFB9")
        }
    }
    var shadow: Color {
        switch self {
        case .yellow: return Color(hex: "C9A41A")
        case .coral:  return Color(hex: "C84A2E")
        case .teal:   return Color(hex: "3F9789")
        case .cream:  return Color(hex: "A8985F")
        }
    }
}
