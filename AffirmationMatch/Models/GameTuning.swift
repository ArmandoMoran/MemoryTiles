import CoreGraphics

enum GameTuning {
    static let columns = 5
    static let rows = 4
    static let cardCount = columns * rows
    static let pairCount = 10

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

    static let affirmations = [
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
    ]
}
