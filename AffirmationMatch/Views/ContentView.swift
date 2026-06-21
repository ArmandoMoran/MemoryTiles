import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AffirmationMatchViewModel()

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @State private var hasStarted = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background

                VStack(spacing: 14) {
                    HeaderBarView(
                        moves: viewModel.moves,
                        matchedPairs: viewModel.matchedPairs,
                        statusMessage: viewModel.statusMessage,
                        soundEnabled: viewModel.soundEnabled,
                        onRestart: viewModel.startNewGame,
                        onToggleSound: viewModel.toggleSound
                    )
                    .padding(.top, max(geometry.safeAreaInsets.top, 10))

                    GameBoardView(
                        cards: viewModel.cards,
                        introStartedAt: viewModel.introStartedAt,
                        introDuration: viewModel.introDuration,
                        introIsActive: viewModel.introIsActive,
                        showWinOverlay: viewModel.showWinOverlay,
                        reduceMotion: accessibilityReduceMotion,
                        canTap: viewModel.canTap,
                        onCardTap: viewModel.choose,
                        onRestart: viewModel.startNewGame,
                        moves: viewModel.moves
                    )
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 10))
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 8)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            viewModel.configureAccessibility(reduceMotion: accessibilityReduceMotion)

            guard !hasStarted else { return }
            hasStarted = true
            viewModel.startNewGame()
        }
        .onChange(of: accessibilityReduceMotion) { _, newValue in
            viewModel.configureAccessibility(reduceMotion: newValue)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.98, blue: 0.99),
                    Color(red: 0.89, green: 0.94, blue: 0.96),
                    Color(red: 0.95, green: 0.96, blue: 0.91)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 0.82, green: 0.92, blue: 0.91).opacity(0.55))
                .frame(width: 380, height: 380)
                .blur(radius: 24)
                .offset(x: -220, y: -90)

            Circle()
                .fill(Color(red: 0.97, green: 0.9, blue: 0.77).opacity(0.36))
                .frame(width: 320, height: 320)
                .blur(radius: 36)
                .offset(x: 220, y: 100)

            RoundedRectangle(cornerRadius: 64, style: .continuous)
                .fill(.white.opacity(0.16))
                .frame(width: 520, height: 260)
                .rotationEffect(.degrees(-8))
                .blur(radius: 2)
                .offset(x: 60, y: -20)
        }
    }
}
