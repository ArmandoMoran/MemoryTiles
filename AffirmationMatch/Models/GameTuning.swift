import CoreGraphics

enum GameTuning {
    static let columns = 5
    static let rows = 4
    static let cardCount = columns * rows
    static let pairCount = 10

    static let cardAspectRatio: CGFloat = 1.32
    static let cardCornerRadius: CGFloat = 18

    static let minimumGridSpacing: CGFloat = 8
    static let preferredGridSpacing: CGFloat = 10
    static let maximumGridSpacing: CGFloat = 14

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

    static let affirmations = [
        "I am loved",
        "I am enough",
        "I am smart",
        "I am strong",
        "I am kind",
        "I am brave",
        "I am capable",
        "I am worthy",
        "I am growing every day",
        "I believe in myself"
    ]
}
