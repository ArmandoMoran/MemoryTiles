import SwiftUI

struct HeaderBarView: View {
    let moves: Int
    let matchedPairs: Int
    let statusMessage: String
    let soundEnabled: Bool
    let onRestart: () -> Void
    let onToggleSound: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Affirmation Match")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.18, green: 0.24, blue: 0.34))

                Text(statusMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.34, green: 0.42, blue: 0.49))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 8)

            statPill(title: "Moves", value: "\(moves)")
            statPill(title: "Pairs", value: "\(matchedPairs)/\(GameTuning.pairCount)")

            Button(action: onToggleSound) {
                Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(GlassButtonStyle(tint: Color(red: 0.87, green: 0.95, blue: 0.98)))
            .accessibilityLabel(soundEnabled ? "Mute sound" : "Enable sound")

            Button(action: onRestart) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(GlassButtonStyle(tint: Color(red: 0.98, green: 0.94, blue: 0.89)))
            .accessibilityLabel("Restart game")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.white.opacity(0.65), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 18, y: 10)
        )
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.51, green: 0.58, blue: 0.63))

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.21, green: 0.28, blue: 0.36))
        }
        .frame(minWidth: 72)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.white.opacity(0.72))
        )
    }
}

private struct GlassButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color(red: 0.24, green: 0.31, blue: 0.38))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tint.opacity(configuration.isPressed ? 0.9 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
