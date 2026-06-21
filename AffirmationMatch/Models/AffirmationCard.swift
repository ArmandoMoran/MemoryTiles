import Foundation

struct AffirmationCard: Identifiable, Equatable {
    let id = UUID()
    let pairID: Int
    let affirmation: String
    let introOrder: Int

    var isFaceUp = false
    var isMatched = false
    var isMatchAnimating = false
}
