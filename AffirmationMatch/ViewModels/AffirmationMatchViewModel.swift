import SwiftUI

@MainActor
final class AffirmationMatchViewModel: ObservableObject {
    @Published private(set) var activeMode: GameMode?
    @Published private(set) var cards: [AffirmationCard] = []
    @Published private(set) var introStartedAt = Date()
    @Published private(set) var introDuration = GameTuning.shuffleDuration
    @Published private(set) var introIsActive = false
    @Published private(set) var moves = 0
    @Published private(set) var matchedPairs = 0
    @Published private(set) var statusMessage = "Select a game to begin."
    @Published private(set) var showWinOverlay = false
    @Published private(set) var soundEnabled = AudioHapticsManager.shared.soundEnabled

    private let audio = AudioHapticsManager.shared
    private var firstSelectionID: UUID?
    private var interactionLocked = true
    private var prefersReducedMotion = false

    private var introTask: Task<Void, Never>?
    private var resolveTask: Task<Void, Never>?

    var isReadyForInput: Bool {
        !introIsActive && !interactionLocked && !showWinOverlay
    }

    func configureAccessibility(reduceMotion: Bool) {
        prefersReducedMotion = reduceMotion
    }

    func selectGame(_ mode: GameMode) {
        activeMode = mode
        startNewGame()
    }

    func startNewGame() {
        guard let activeMode else { return }
        cancelTasks()

        var deck: [AffirmationCard] = []
        var introOrders = Array(0..<activeMode.cardCount).shuffled()

        for (pairID, affirmation) in activeMode.phrases.enumerated() {
            deck.append(AffirmationCard(pairID: pairID, affirmation: affirmation, introOrder: introOrders.removeFirst()))
            deck.append(AffirmationCard(pairID: pairID, affirmation: affirmation, introOrder: introOrders.removeFirst()))
        }

        deck.shuffle()

        cards = deck
        introStartedAt = Date()
        introDuration = prefersReducedMotion ? GameTuning.reducedMotionShuffleDuration : GameTuning.shuffleDuration
        introIsActive = true
        interactionLocked = true
        firstSelectionID = nil
        moves = 0
        matchedPairs = 0
        showWinOverlay = false
        statusMessage = "Shuffling affirmations..."

        introTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(introDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await self.finishIntro()
        }
    }

    func choose(_ card: AffirmationCard) {
        guard isReadyForInput else { return }
        guard let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[selectedIndex].isFaceUp, !cards[selectedIndex].isMatched else { return }

        withAnimation(.easeInOut(duration: GameTuning.flipDuration)) {
            cards[selectedIndex].isFaceUp = true
        }

        audio.playFlip()

        if firstSelectionID == nil {
            firstSelectionID = card.id
            statusMessage = "Pick one more card and trust your memory."
            return
        }

        guard let firstID = firstSelectionID, firstID != card.id else { return }

        firstSelectionID = nil
        interactionLocked = true
        moves += 1

        resolveSelection(firstID: firstID, secondID: card.id)
    }

    func canTap(_ card: AffirmationCard) -> Bool {
        isReadyForInput && !card.isFaceUp && !card.isMatched
    }

    func toggleSound() {
        audio.toggleSound()
        soundEnabled = audio.soundEnabled
    }

    func returnHome() {
        cancelTasks()
        activeMode = nil
        cards = []
        introIsActive = false
        interactionLocked = true
        firstSelectionID = nil
        moves = 0
        matchedPairs = 0
        showWinOverlay = false
        statusMessage = "Select a game to begin."
    }

    private func finishIntro() {
        introIsActive = false
        interactionLocked = false
        statusMessage = "Find the matching affirmations."
    }

    private func resolveSelection(firstID: UUID, secondID: UUID) {
        guard
            let firstIndex = cards.firstIndex(where: { $0.id == firstID }),
            let secondIndex = cards.firstIndex(where: { $0.id == secondID })
        else {
            interactionLocked = false
            return
        }

        if cards[firstIndex].pairID == cards[secondIndex].pairID {
            statusMessage = "A calm match. Keep going."

            resolveTask = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(nanoseconds: UInt64(0.16 * 1_000_000_000))
                guard !Task.isCancelled else { return }

                withAnimation(.spring(response: 0.46, dampingFraction: 0.76)) {
                    self.cards[firstIndex].isMatched = true
                    self.cards[secondIndex].isMatched = true
                    self.cards[firstIndex].isMatchAnimating = true
                    self.cards[secondIndex].isMatchAnimating = true
                }

                self.matchedPairs += 1
                self.audio.playMatch()

                try? await Task.sleep(nanoseconds: UInt64(GameTuning.matchPulseDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }

                withAnimation(.easeOut(duration: 0.24)) {
                    self.cards[firstIndex].isMatchAnimating = false
                    self.cards[secondIndex].isMatchAnimating = false
                }

                if self.matchedPairs == self.activeMode?.pairCount {
                    self.finishGame()
                } else {
                    self.interactionLocked = false
                    self.statusMessage = "Find the matching affirmations."
                }
            }
        } else {
            statusMessage = "Not a match. Breathe and try again."

            resolveTask = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(nanoseconds: UInt64(GameTuning.mismatchDelay * 1_000_000_000))
                guard !Task.isCancelled else { return }

                withAnimation(.easeInOut(duration: GameTuning.flipDuration)) {
                    self.cards[firstIndex].isFaceUp = false
                    self.cards[secondIndex].isFaceUp = false
                }

                self.interactionLocked = false
                self.statusMessage = "Find the matching affirmations."
            }
        }
    }

    private func finishGame() {
        interactionLocked = true
        statusMessage = "Every affirmation is matched."
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            showWinOverlay = true
        }
        audio.playWin()
    }

    private func cancelTasks() {
        introTask?.cancel()
        resolveTask?.cancel()
        introTask = nil
        resolveTask = nil
    }
}
