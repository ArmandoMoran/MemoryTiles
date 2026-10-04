import CoreGraphics

enum GameModeID: String, Hashable {
    case power
    case support
    case confidence
    case belief
    case calm
}

struct GameMode: Identifiable, Hashable {
    let id: GameModeID
    let name: String
    let cardBackImageName: String
    let phrases: [String]
    let columns: Int

    var pairCount: Int { phrases.count }
    var cardCount: Int { pairCount * 2 }
    var rows: Int { Int(ceil(Double(cardCount) / Double(columns))) }

    static let all: [GameMode] = [
        GameMode(
            id: .power,
            name: "Power",
            cardBackImageName: "PowerTileBack",
            phrases: [
                "I am powerful",
                "I am fearless",
                "I am unstoppable",
                "I stand strong",
                "I have courage",
                "I am fierce",
                "I choose courage",
                "I own my power",
                "I rise stronger",
                "I am bold"
            ],
            columns: 5
        ),
        GameMode(
            id: .support,
            name: "Support",
            cardBackImageName: "SupportTileBack",
            phrases: [
                "I am not alone",
                "I trust myself",
                "I will smile",
                "I will love",
                "I will heal",
                "I am resilient",
                "I will be comforted",
                "I will rest",
                "I am supported",
                "I choose hope",
                "I am strong",
                "I care for myself"
            ],
            columns: 6
        ),
        GameMode(
            id: .confidence,
            name: "Confidence",
            cardBackImageName: "ConfidenceTileBack",
            phrases: [
                "I am prepared",
                "I got this",
                "I am focused",
                "I am ready",
                "I am capable",
                "I am calm",
                "My mind is clear",
                "My mind is sharp",
                "I will ROCK this",
                "I am a superstar"
            ],
            columns: 5
        ),
        GameMode(
            id: .belief,
            name: "Belief",
            cardBackImageName: "SmilingFlowerTileBack",
            phrases: [
                "I am present",
                "I am calm",
                "I am capable",
                "I am focused",
                "I am loved",
                "I belong",
                "I am patient",
                "I am confident",
                "I am grateful",
                "I am enough"
            ],
            columns: 5
        ),
        GameMode(
            id: .calm,
            name: "Calm",
            cardBackImageName: "CalmTileBack",
            phrases: [
                "Breathe",
                "Focus",
                "Believe",
                "Steady now",
                "Love",
                "Re-center",
                "Release the tension",
                "Stillness",
                "Slow down",
                "Let go"
            ],
            columns: 5
        )
    ]
}

enum GameTuning {
    static let cardCornerRadius: CGFloat = 18

    static let minimumGridSpacing: CGFloat = 7
    static let preferredGridSpacing: CGFloat = 9
    static let maximumGridSpacing: CGFloat = 12

    static let shuffleDuration: Double = 3.35
    static let reducedMotionShuffleDuration: Double = 0.9
    static let shufflePerCardDelay: Double = 0.03
    static let shuffleMotionIntensity: CGFloat = 0.82

    static let flipDuration: Double = 0.42
    static let mismatchDelay: Double = 0.92
    static let matchPulseDuration: Double = 0.58
    static let endGameCelebrationDuration: Double = 1.3

    static let matchAnimationScale: CGFloat = 1.045
    static let matchGlowOpacity: Double = 0.42
}
