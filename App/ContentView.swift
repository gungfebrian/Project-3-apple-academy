import SwiftUI

struct ContentView: View {
    @State private var screen: AppScreen = .home

    var body: some View {
        switch screen {
        case .home:
            HomeView { game in screen = .setup(game: game) }

        case .setup(let game):
            SetupView(game: game) {
                screen = .home
            } onStart: { diff, dur, lang in
                screen = .play(difficulty: diff, duration: dur, lang: lang)
            }

        case .play(let diff, let dur, let lang):
            GameplayView(difficulty: diff, duration: dur, lang: lang) { sc, ct, ms in
                screen = .results(score: sc, caught: ct, missed: ms,
                                  difficulty: diff, duration: dur, lang: lang)
            } onExit: {
                screen = .home
            }

        case .results(let sc, let ct, let ms, let diff, let dur, let lang):
            ResultsView(score: sc, caught: ct, missed: ms) {
                screen = .play(difficulty: diff, duration: dur, lang: lang)
            } onHome: {
                screen = .home
            }
        }
    }
}

#Preview { ContentView() }
