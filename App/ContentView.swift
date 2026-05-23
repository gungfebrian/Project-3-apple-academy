import SwiftUI

struct ContentView: View {
    @State private var screen: AppScreen = .home

    var body: some View {
        switch screen {
        case .home:
            HomeView { players in
                screen = .setup(game: "catch", players: players)
            }

        case .setup(_, let players):
            SetupView(initialPlayers: players) {
                screen = .home
            } onStart: { diff, dur, lang, pl in
                screen = .play(difficulty: diff, duration: dur, lang: lang, players: pl)
            }

        case .play(let diff, let dur, let lang, let players):
            GameplayView(difficulty: diff, duration: dur, lang: lang, players: players) { p1, p2 in
                screen = .results(p1Score: p1, p2Score: p2, players: players,
                                  difficulty: diff, duration: dur, lang: lang)
            } onExit: {
                screen = .home
            }

        case .results(let p1, let p2, let players, let diff, let dur, let lang):
            ResultsView(p1Score: p1, p2Score: p2, players: players) {
                screen = .play(difficulty: diff, duration: dur, lang: lang, players: players)
            } onHome: {
                screen = .home
            }
        }
    }
}

#Preview { ContentView() }
