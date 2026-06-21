import AVFoundation
import UIKit

@MainActor
final class AudioHapticsManager: ObservableObject {
    static let shared = AudioHapticsManager()

    @Published private(set) var soundEnabled: Bool

    private let defaultsKey = "affirmationMatch.soundEnabled"
    private var players: [Cue: AVAudioPlayer] = [:]

    private enum Cue: String, CaseIterable {
        case flip
        case match
        case win
    }

    private init() {
        soundEnabled = UserDefaults.standard.object(forKey: defaultsKey) as? Bool ?? true
    }

    func prepare() {
        configureAudioSession()
        loadPlayersIfNeeded()
    }

    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: defaultsKey)
    }

    func toggleSound() {
        setSoundEnabled(!soundEnabled)
    }

    func playFlip() {
        play(.flip)
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred(intensity: 0.7)
    }

    func playMatch() {
        play(.match)
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.success)
    }

    func playWin() {
        play(.win)
        let feedback = UIImpactFeedbackGenerator(style: .soft)
        feedback.prepare()
        feedback.impactOccurred(intensity: 0.95)
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // If audio session setup fails, the game still plays normally without sound.
        }
    }

    private func loadPlayersIfNeeded() {
        guard players.isEmpty else { return }

        for cue in Cue.allCases {
            guard let url = Bundle.main.url(forResource: cue.rawValue, withExtension: "wav") else { continue }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[cue] = player
            } catch {
                // Missing or unreadable audio should not stop the app from working.
            }
        }
    }

    private func play(_ cue: Cue) {
        guard soundEnabled else { return }

        if players.isEmpty {
            loadPlayersIfNeeded()
        }

        guard let player = players[cue] else { return }
        player.currentTime = 0
        player.play()
    }
}
