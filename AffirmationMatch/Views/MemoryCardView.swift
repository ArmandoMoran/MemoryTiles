import SwiftUI

struct MemoryCardView: View {
    let card: AffirmationCard
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { geometry in
            let isFrontVisible = card.isFaceUp || card.isMatched
            let pulseScale = card.isMatchAnimating ? GameTuning.matchAnimationScale : 1.0

            ZStack {
                if reduceMotion {
                    ZStack {
                        backFace(in: geometry.size)
                            .opacity(isFrontVisible ? 0 : 1)

                        frontFace(in: geometry.size)
                            .opacity(isFrontVisible ? 1 : 0)
                    }
                } else {
                    ZStack {
                        backFace(in: geometry.size)
                            .opacity(isFrontVisible ? 0 : 1)
                            .rotation3DEffect(
                                .degrees(isFrontVisible ? -90 : 0),
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.55
                            )

                        frontFace(in: geometry.size)
                            .opacity(isFrontVisible ? 1 : 0)
                            .rotation3DEffect(
                                .degrees(isFrontVisible ? 0 : 90),
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.55
                            )
                    }
                }
            }
            .scaleEffect(pulseScale)
            .animation(.easeInOut(duration: GameTuning.flipDuration), value: isFrontVisible)
            .animation(.spring(response: 0.42, dampingFraction: 0.72), value: pulseScale)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel(isFrontVisible: isFrontVisible))
        }
    }

    private func frontFace(in size: CGSize) -> some View {
        let style = PairVisualStyle.palette[card.pairID % PairVisualStyle.palette.count]
        let fontSize = min(25, max(12, min(size.height * 0.24, size.width * 0.16)))

        return RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [style.top, style.bottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
                    .stroke(card.isMatched ? style.accent : Color.white.opacity(0.82), lineWidth: card.isMatched ? 2.4 : 1.2)
            )
            .overlay {
                Text(card.affirmation)
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.20, green: 0.18, blue: 0.24))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
                    .padding(.horizontal, max(8, size.width * 0.07))
                    .padding(.vertical, max(5, size.height * 0.10))
            }
            .shadow(color: Color(red: 0.28, green: 0.28, blue: 0.34).opacity(0.09), radius: 10, y: 6)
            .overlay {
                if card.isMatched {
                    RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
                        .stroke(style.accent.opacity(GameTuning.matchGlowOpacity), lineWidth: 5)
                }
            }
    }

    private func backFace(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.54, green: 0.90, blue: 0.91),
                        Color(red: 0.72, green: 0.72, blue: 0.95),
                        Color(red: 0.98, green: 0.69, blue: 0.78)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.72), lineWidth: 1.4)
            )
            .overlay {
                Image("SmilingFlowerTileBack")
                    .resizable()
                    .scaledToFit()
                    .padding(max(4, min(size.width, size.height) * 0.075))
            }
            .overlay {
                RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius - 5, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    .padding(5)
            }
            .shadow(color: Color(red: 0.30, green: 0.24, blue: 0.42).opacity(0.18), radius: 10, y: 6)
    }

    private func accessibilityLabel(isFrontVisible: Bool) -> String {
        if card.isMatched {
            return "Matched card, \(card.affirmation)"
        }

        if isFrontVisible {
            return card.affirmation
        }

        return "Hidden affirmation card"
    }
}

private struct PairVisualStyle {
    let top: Color
    let bottom: Color
    let accent: Color

    static let palette: [PairVisualStyle] = [
        PairVisualStyle(
            top: Color(red: 0.70, green: 0.94, blue: 0.93),
            bottom: Color(red: 0.52, green: 0.84, blue: 0.84),
            accent: Color(red: 0.20, green: 0.57, blue: 0.60)
        ),
        PairVisualStyle(
            top: Color(red: 0.75, green: 0.90, blue: 0.99),
            bottom: Color(red: 0.61, green: 0.79, blue: 0.96),
            accent: Color(red: 0.28, green: 0.51, blue: 0.78)
        ),
        PairVisualStyle(
            top: Color(red: 0.87, green: 0.81, blue: 0.98),
            bottom: Color(red: 0.74, green: 0.67, blue: 0.93),
            accent: Color(red: 0.46, green: 0.35, blue: 0.72)
        ),
        PairVisualStyle(
            top: Color(red: 0.96, green: 0.82, blue: 0.95),
            bottom: Color(red: 0.88, green: 0.69, blue: 0.88),
            accent: Color(red: 0.66, green: 0.35, blue: 0.62)
        ),
        PairVisualStyle(
            top: Color(red: 0.99, green: 0.83, blue: 0.88),
            bottom: Color(red: 0.95, green: 0.69, blue: 0.77),
            accent: Color(red: 0.74, green: 0.34, blue: 0.46)
        ),
        PairVisualStyle(
            top: Color(red: 1.00, green: 0.82, blue: 0.73),
            bottom: Color(red: 0.98, green: 0.68, blue: 0.60),
            accent: Color(red: 0.76, green: 0.34, blue: 0.26)
        ),
        PairVisualStyle(
            top: Color(red: 1.00, green: 0.89, blue: 0.72),
            bottom: Color(red: 0.98, green: 0.78, blue: 0.58),
            accent: Color(red: 0.73, green: 0.47, blue: 0.18)
        ),
        PairVisualStyle(
            top: Color(red: 1.00, green: 0.95, blue: 0.70),
            bottom: Color(red: 0.97, green: 0.87, blue: 0.52),
            accent: Color(red: 0.66, green: 0.53, blue: 0.12)
        ),
        PairVisualStyle(
            top: Color(red: 0.78, green: 0.95, blue: 0.79),
            bottom: Color(red: 0.63, green: 0.86, blue: 0.68),
            accent: Color(red: 0.30, green: 0.60, blue: 0.36)
        ),
        PairVisualStyle(
            top: Color(red: 0.68, green: 0.91, blue: 0.83),
            bottom: Color(red: 0.52, green: 0.80, blue: 0.74),
            accent: Color(red: 0.21, green: 0.55, blue: 0.49)
        )
    ]
}
