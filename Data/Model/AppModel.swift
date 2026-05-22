import Foundation

// MARK: - Navigation

enum AppScreen {
    case home
    case setup(game: String)
    case play(difficulty: Difficulty, duration: Int, lang: GameLang)
    case results(score: Int, caught: [String], missed: [String],
                 difficulty: Difficulty, duration: Int, lang: GameLang)
}

// MARK: - Difficulty

enum Difficulty: String, CaseIterable, Equatable {
    case gentle, lively, speedy

    var label: String { rawValue.capitalized }
    var emoji: String { ["gentle": "🌿", "lively": "🍃", "speedy": "💨"][rawValue]! }
    var sub: String   { ["gentle": "slow drift", "lively": "medium", "speedy": "fast"][rawValue]! }
    var speedMult: Double { ["gentle": 0.9, "lively": 1.2, "speedy": 1.6][rawValue]! }
    var spawnInterval: Double { ["gentle": 2.0, "lively": 1.5, "speedy": 1.1][rawValue]! }
}

// MARK: - Language

enum GameLang: String, CaseIterable, Equatable {
    case english = "en", indonesian = "id"

    var label: String { self == .english ? "English" : "Indonesian" }
    var flag: String  { self == .english ? "🇬🇧" : "🇮🇩" }

    var wordBank: [String] {
        switch self {
        case .english:
            return ["cloud", "garden", "sunshine", "window", "family", "tea", "photo",
                    "butterfly", "kettle", "letter", "umbrella", "smile", "ocean",
                    "book", "blanket", "memory", "laugh", "spoon"]
        case .indonesian:
            return ["awan", "kebun", "matahari", "jendela", "keluarga", "teh", "foto",
                    "kupu-kupu", "teko", "surat", "payung", "senyum", "laut",
                    "buku", "selimut", "kenangan", "tawa", "sendok"]
        }
    }
}

// MARK: - Tab

enum AppTab { case home, streak, family, me }
