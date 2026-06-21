import SwiftUI

struct WinOverlayView: View {
    let moves: Int
    let onRestart: () -> Void

    @State private var animateGlow = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.98, green: 0.89, blue: 0.67).opacity(0.32))
                .frame(width: animateGlow ? 260 : 220, height: animateGlow ? 260 : 220)
                .blur(radius: 8)

            Circle()
                .fill(Color(red: 0.71, green: 0.88, blue: 0.83).opacity(0.28))
                .frame(width: animateGlow ? 320 : 280, height: animateGlow ? 320 : 280)
                .blur(radius: 16)

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(red: 0.85, green: 0.7, blue: 0.35))

                Text("All 10 pairs matched")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.21, green: 0.28, blue: 0.36))

                Text("A calm finish in \(moves) moves.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.35, green: 0.43, blue: 0.49))

                Button(action: onRestart) {
                    Text("Play Again")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.42, green: 0.71, blue: 0.68),
                                            Color(red: 0.3, green: 0.58, blue: 0.62)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white.opacity(0.84))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.74), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 24, y: 12)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.94, green: 0.97, blue: 0.98).opacity(0.45))
        .onAppear {
            withAnimation(
                .easeInOut(duration: GameTuning.endGameCelebrationDuration)
                .repeatForever(autoreverses: true)
            ) {
                animateGlow = true
            }
        }
    }
}
