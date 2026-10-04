import SwiftUI

struct HeaderBarView: View {
    let gameName: String
    let moves: Int
    let matchedPairs: Int
    let totalPairs: Int
    let statusMessage: String
    let soundEnabled: Bool
    let onRestart: () -> Void
    let onToggleSound: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Uplifting\nMemory Match")
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.18, green: 0.24, blue: 0.34))
                    .lineSpacing(-2)
                    .minimumScaleFactor(0.8)

                Text(statusMessage)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.34, green: 0.42, blue: 0.49))
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)

                Text(gameName)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.30, green: 0.58, blue: 0.62))
            }

            Spacer(minLength: 2)

            HStack(spacing: 7) {
                statPill(title: "Moves", value: "\(moves)")
                statPill(title: "Pairs", value: "\(matchedPairs)/\(totalPairs)")
            }

            HStack(spacing: 6) {
                Button(action: onHome) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .buttonStyle(GlassButtonStyle(tint: Color(red: 0.92, green: 0.94, blue: 0.99)))
                .accessibilityLabel("Return to game selection")

                Button(action: onToggleSound) {
                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .buttonStyle(GlassButtonStyle(tint: Color(red: 0.87, green: 0.95, blue: 0.98)))
                .accessibilityLabel(soundEnabled ? "Mute sound" : "Enable sound")

                Button(action: onRestart) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .buttonStyle(GlassButtonStyle(tint: Color(red: 0.98, green: 0.92, blue: 0.88)))
                .accessibilityLabel("Restart game")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
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
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.21, green: 0.28, blue: 0.36))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 5)
        .padding(.vertical, 8)
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
