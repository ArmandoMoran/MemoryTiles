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
        let fontSize = min(size.height * 0.25, size.width * 0.19)

        return RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.997, green: 0.991, blue: 0.977),
                        Color(red: 0.978, green: 0.965, blue: 0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
                    .stroke(card.isMatched ? Color(red: 0.58, green: 0.81, blue: 0.7) : Color.white.opacity(0.9), lineWidth: 1.2)
            )
            .overlay(alignment: .topTrailing) {
                Image(systemName: "sparkles")
                    .font(.system(size: max(12, size.height * 0.12), weight: .semibold))
                    .foregroundStyle(Color(red: 0.89, green: 0.74, blue: 0.45))
                    .padding(10)
                    .opacity(0.85)
            }
            .overlay {
                Text(card.affirmation)
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.22, green: 0.29, blue: 0.36))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, size.width * 0.1)
                    .padding(.vertical, size.height * 0.18)
            }
            .shadow(color: Color(red: 0.28, green: 0.28, blue: 0.34).opacity(0.09), radius: 10, y: 6)
            .overlay {
                if card.isMatched {
                    RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
                        .fill(Color(red: 0.73, green: 0.92, blue: 0.82).opacity(GameTuning.matchGlowOpacity))
                }
            }
    }

    private func backFace(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.45, green: 0.71, blue: 0.79),
                        Color(red: 0.27, green: 0.49, blue: 0.64)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1.2)
            )
            .overlay {
                VStack(spacing: size.height * 0.07) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: min(size.height * 0.26, 22), weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))

                    Text("Affirm")
                        .font(.system(size: min(size.height * 0.15, 14), weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                        .tracking(0.8)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: GameTuning.cardCornerRadius - 5, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    .padding(7)
            }
            .shadow(color: Color(red: 0.11, green: 0.19, blue: 0.28).opacity(0.18), radius: 12, y: 8)
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
