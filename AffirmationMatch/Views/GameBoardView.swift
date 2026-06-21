import SwiftUI

struct GameBoardView: View {
    let cards: [AffirmationCard]
    let introStartedAt: Date
    let introDuration: Double
    let introIsActive: Bool
    let showWinOverlay: Bool
    let reduceMotion: Bool
    let canTap: (AffirmationCard) -> Bool
    let onCardTap: (AffirmationCard) -> Void
    let onRestart: () -> Void
    let moves: Int

    var body: some View {
        GeometryReader { geometry in
            let metrics = BoardLayout.metrics(in: geometry.size)

            ZStack {
                boardBackground(frame: metrics.boardFrame)

                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !introIsActive)) { context in
                    let elapsed = max(0, context.date.timeIntervalSince(introStartedAt))

                    ZStack {
                        ForEach(Array(cards.enumerated()), id: \.element.id) { entry in
                            let index = entry.offset
                            let card = entry.element
                            let frame = metrics.frame(for: index)
                            let pose = pose(for: card, finalFrame: frame, boardSize: geometry.size, elapsed: elapsed)

                            MemoryCardView(card: card, reduceMotion: reduceMotion)
                                .frame(width: metrics.cardSize.width, height: metrics.cardSize.height)
                                .position(pose.center)
                                .rotationEffect(.degrees(pose.rotation))
                                .scaleEffect(pose.scale)
                                .zIndex(card.isFaceUp || card.isMatched ? 200 : pose.zIndex)
                                .allowsHitTesting(false)
                        }
                    }
                }

                tapLayer(metrics: metrics)

                if introIsActive {
                    introLabel
                        .position(x: metrics.boardFrame.midX, y: metrics.boardFrame.minY - 26)
                        .transition(.opacity)
                }

                if showWinOverlay {
                    WinOverlayView(moves: moves, onRestart: onRestart)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
        }
    }

    private func tapLayer(metrics: BoardMetrics) -> some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { entry in
                let index = entry.offset
                let card = entry.element
                let frame = metrics.frame(for: index)

                // Keep input separate from the animated card view so each visible cell has
                // one stable, predictable tap target after the intro shuffle settles.
                Color.clear
                    .frame(width: metrics.cardSize.width, height: metrics.cardSize.height)
                    .contentShape(RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous))
                    .position(x: frame.midX, y: frame.midY)
                    .allowsHitTesting(canTap(card))
                    .onTapGesture {
                        onCardTap(card)
                    }
                    .accessibilityLabel(accessibilityLabel(for: card))
                    .accessibilityAddTraits(.isButton)
            }
        }
        .allowsHitTesting(!introIsActive && !showWinOverlay)
    }

    private func pose(for card: AffirmationCard, finalFrame: CGRect, boardSize: CGSize, elapsed: Double) -> ShufflePose {
        guard introIsActive else {
            return ShufflePlanner.finalPose(for: finalFrame)
        }

        let progress = ShufflePlanner.localProgress(
            for: card.introOrder,
            elapsed: elapsed,
            duration: introDuration,
            reduceMotion: reduceMotion
        )

        return ShufflePlanner.pose(
            for: card.introOrder,
            finalFrame: finalFrame,
            boardSize: boardSize,
            progress: progress,
            reduceMotion: reduceMotion
        )
    }

    private func boardBackground(frame: CGRect) -> some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(.white.opacity(0.24))
            .frame(width: frame.width + 28, height: frame.height + 28)
            .position(x: frame.midX, y: frame.midY)
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(.white.opacity(0.34), lineWidth: 1)
                    .frame(width: frame.width + 28, height: frame.height + 28)
                    .position(x: frame.midX, y: frame.midY)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 24, y: 14)
    }

    private var introLabel: some View {
        Text("Shuffling into place...")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(red: 0.34, green: 0.43, blue: 0.5))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.white.opacity(0.75))
            )
    }

    private func accessibilityLabel(for card: AffirmationCard) -> String {
        if card.isMatched {
            return "Matched card, \(card.affirmation)"
        }

        if card.isFaceUp {
            return card.affirmation
        }

        return "Hidden affirmation card"
    }
}
