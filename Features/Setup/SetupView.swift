import SwiftUI

struct SetupView: View {
    let initialPlayers: Int
    let onBack: () -> Void
    let onStart: (Difficulty, Int, GameLang, Int) -> Void

    @State private var players: Int
    @State private var difficulty: Difficulty = .gentle

    init(initialPlayers: Int,
         onBack: @escaping () -> Void,
         onStart: @escaping (Difficulty, Int, GameLang, Int) -> Void) {
        self.initialPlayers = initialPlayers
        self.onBack = onBack
        self.onStart = onStart
        _players = State(initialValue: initialPlayers)
    }

    var body: some View {
        ZStack {
            Color.sunnyBg.ignoresSafeArea()
            ZStack {
                RadialGradient(colors: [Color(hex: "FFE9A8"), .clear],
                               center: .topLeading, startRadius: 0, endRadius: 300)
                    .opacity(0.6)
            }
            .ignoresSafeArea().allowsHitTesting(false)

            // Back button (top-left, after safe area)
            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.sunnyInk)
                            .frame(width: 44, height: 44)
                            .background(Color.sunnyPaper)
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.sunnyRule, lineWidth: 1.5))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.top, 14)
                .padding(.trailing, 22)
                Spacer()
            }

            // Main two-column layout
            HStack(alignment: .center, spacing: 32) {
                // LEFT — title + one-line instruction
                VStack(alignment: .leading, spacing: 0) {
                    Text("Get ready")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.sunnyInk2)
                        .tracking(2)
                        .textCase(.uppercase)

                    Text("Catch the\nWords")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                        .foregroundColor(.sunnyInk)
                        .lineSpacing(-2)
                        .padding(.top, 6)

                    Text(players == 2
                         ? "Stand together. Reach up to grab words before they fall."
                         : "Reach up to grab words before they fall to the ground.")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundColor(.sunnyInk)
                        .lineSpacing(3)
                        .padding(.top, 16)
                        .frame(maxWidth: 280, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // RIGHT — player picker + start button + speed chips
                VStack(spacing: 14) {
                    // Players
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Players")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.sunnyInk2)
                            .tracking(2)
                            .textCase(.uppercase)

                        HStack(spacing: 10) {
                            playerButton(count: 1, icon: "👤")
                            playerButton(count: 2, icon: "👥")
                        }
                    }

                    // Big start button
                    Button {
                        onStart(difficulty, 60, .english, players)
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 22, weight: .bold))
                            Text("Start")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.sunnyLemon)
                        .frame(maxWidth: .infinity)
                        .frame(height: 84)
                        .background(Color.sunnyInk)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: .black, radius: 0, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)

                    // Tiny speed chips
                    HStack(spacing: 6) {
                        Text("Speed:")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.sunnyInk3)
                        ForEach(Difficulty.allCases, id: \.self) { d in
                            Button { difficulty = d } label: {
                                Text(d.label)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(difficulty == d ? .sunnyLemon : .sunnyInk2)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                                    .background(difficulty == d ? Color.sunnyInk : Color.clear)
                                    .overlay(Capsule()
                                        .stroke(difficulty == d ? Color.clear : Color.sunnyRule, lineWidth: 1))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.trailing, 22)
            .padding(.top, 60)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func playerButton(count: Int, icon: String) -> some View {
        let sel = players == count
        Button { players = count } label: {
            HStack(spacing: 12) {
                Text(icon).font(.system(size: 26))
                Text("\(count)")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(sel ? .sunnyLemon : .sunnyInk)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(sel ? Color.sunnyInk : Color.sunnyPaper)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(sel ? Color.clear : Color.sunnyRule, lineWidth: 1.5))
            .shadow(color: sel ? .black : Color(hex: "E0D4A6"), radius: 0, x: 0, y: sel ? 4 : 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview { SetupView(initialPlayers: 1, onBack: {}, onStart: { _, _, _, _ in }) }
