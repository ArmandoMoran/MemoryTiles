import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AffirmationMatchViewModel()

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background
                    .ignoresSafeArea()

                if let activeMode = viewModel.activeMode {
                    gameView(for: activeMode, in: geometry)
                        .transition(.opacity.combined(with: .scale(scale: 0.99)))
                } else {
                    HomeSelectionView(
                        modes: GameMode.all,
                        onSelect: viewModel.selectGame
                    )
                    .transition(.opacity.combined(with: .scale(scale: 1.01)))
                }
            }
            .animation(.easeInOut(duration: 0.28), value: viewModel.activeMode?.id)
        }
        .onAppear {
            viewModel.configureAccessibility(reduceMotion: accessibilityReduceMotion)
        }
        .onChange(of: accessibilityReduceMotion) { _, newValue in
            viewModel.configureAccessibility(reduceMotion: newValue)
        }
    }

    private func gameView(for mode: GameMode, in geometry: GeometryProxy) -> some View {
        HStack(spacing: 10) {
            HeaderBarView(
                gameName: mode.name,
                moves: viewModel.moves,
                matchedPairs: viewModel.matchedPairs,
                totalPairs: mode.pairCount,
                statusMessage: viewModel.statusMessage,
                soundEnabled: viewModel.soundEnabled,
                onRestart: viewModel.startNewGame,
                onToggleSound: viewModel.toggleSound,
                onHome: viewModel.returnHome
            )
            .frame(width: sidePanelWidth(for: geometry.size))

            GameBoardView(
                cards: viewModel.cards,
                mode: mode,
                introStartedAt: viewModel.introStartedAt,
                introDuration: viewModel.introDuration,
                introIsActive: viewModel.introIsActive,
                showWinOverlay: viewModel.showWinOverlay,
                reduceMotion: accessibilityReduceMotion,
                canTap: viewModel.canTap,
                onCardTap: viewModel.choose,
                onHome: viewModel.returnHome,
                moves: viewModel.moves
            )
        }
        .padding(.leading, max(geometry.safeAreaInsets.leading, 8))
        .padding(.trailing, max(geometry.safeAreaInsets.trailing, 8))
        .padding(.top, max(geometry.safeAreaInsets.top, 8))
        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 8))
    }

    private func sidePanelWidth(for size: CGSize) -> CGFloat {
        min(215, max(155, size.width * 0.19))
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

private struct HomeSelectionView: View {
    let modes: [GameMode]
    let onSelect: (GameMode) -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: geometry.size.height < 390 ? 12 : 20) {
                    VStack(spacing: 5) {
                        Text("Uplifting Memory Match")
                            .font(.system(size: min(38, max(27, geometry.size.width * 0.042)), weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.18, green: 0.24, blue: 0.34))
                            .multilineTextAlignment(.center)

                        Text("Select a game to begin")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 0.34, green: 0.42, blue: 0.49))
                    }

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: geometry.size.width < 760 ? 112 : 140), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(modes) { mode in
                            GameSelectionButton(mode: mode) {
                                onSelect(mode)
                            }
                        }
                    }
                }
                .padding(.horizontal, max(20, geometry.safeAreaInsets.leading + 16))
                .padding(.vertical, geometry.size.height < 390 ? 14 : 24)
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct GameSelectionButton: View {
    let mode: GameMode
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(mode.cardBackImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 96)

                Text(mode.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.21, green: 0.28, blue: 0.36))

                Text("\(mode.pairCount) pairs")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.59))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.68))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.75), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.07), radius: 15, y: 8)
            )
        }
        .buttonStyle(HomeGameButtonStyle())
        .accessibilityLabel("\(mode.name) game, \(mode.pairCount) pairs")
    }
}

private struct HomeGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
