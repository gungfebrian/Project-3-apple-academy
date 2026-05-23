import SwiftUI

struct ResultsView: View {
    let p1Score: Int
    let p2Score: Int
    let players: Int
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    private var isVs: Bool { players == 2 }
    private var stars: Int { p1Score >= 8 ? 3 : p1Score >= 5 ? 2 : 1 }
    private var winner: String {
        guard isVs else { return "solo" }
        if p1Score > p2Score { return "p1" }
        if p2Score > p1Score { return "p2" }
        return "tie"
    }

    var body: some View {
        ZStack {
            Color.sunnyBg.ignoresSafeArea()
            ZStack {
                RadialGradient(colors: [Color(hex: "FFE9A8"), .clear],
                               center: .top, startRadius: 0, endRadius: 300)
                    .opacity(0.5)
                RadialGradient(colors: [Color(hex: "FFD9CB"), .clear],
                               center: .bottomTrailing, startRadius: 0, endRadius: 350)
                    .opacity(0.4)
            }
            .ignoresSafeArea().allowsHitTesting(false)

            if isVs {
                vsLayout
            } else {
                soloLayout
            }
        }
    }

    // MARK: - Solo layout

    private var soloLayout: some View {
        VStack(spacing: 0) {
            Spacer()

            // Stars
            HStack(spacing: 8) {
                starView(1)
                starView(2)
                starView(3)
            }

            // Big score
            Text("\(p1Score)")
                .font(.system(size: 110, weight: .heavy, design: .rounded))
                .foregroundColor(.sunnyInk)
                .padding(.top, 8)

            Text(p1Score == 1 ? "word caught" : "words caught")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.sunnyInk2)

            Spacer()

            actionRow(primaryLabel: "Play again")
                .padding(.horizontal, 22)
                .padding(.bottom, 22)
        }
    }

    // MARK: - VS layout

    private var vsLayout: some View {
        let winnerColor: Color = winner == "p1" ? Color(hex: "C9A41A")
                               : winner == "p2" ? Color(hex: "C84A2E")
                               : .sunnyInk
        let emoji   = winner == "tie" ? "🤝" : "🏆"
        let headline = winner == "tie" ? "It's a tie!"
                     : winner == "p1"  ? "Player 1 wins!"
                     : "Player 2 wins!"
        return VStack(spacing: 0) {
            Spacer()

            Text(emoji).font(.system(size: 70))

            Text(headline)
                .font(.system(size: 58, weight: .heavy, design: .rounded))
                .foregroundColor(winnerColor)
                .multilineTextAlignment(.center)
                .padding(.top, 6)

            scoreRow.padding(.top, 14)

            Spacer()

            actionRow(primaryLabel: "Rematch")
                .padding(.horizontal, 22)
                .padding(.bottom, 22)
        }
    }

    private var scoreRow: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text("P1")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk2)
                    .tracking(2)
                Text("\(p1Score)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "C9A41A"))
            }
            Text("–")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.sunnyInk3)
            VStack(spacing: 2) {
                Text("P2")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk2)
                    .tracking(2)
                Text("\(p2Score)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "C84A2E"))
            }
        }
    }

    // MARK: - Helpers

    private func starView(_ index: Int) -> some View {
        Text("⭐")
            .font(.system(size: 50))
            .opacity(index <= stars ? 1 : 0.25)
            .grayscale(index <= stars ? 0 : 1)
            .scaleEffect(index == 2 ? 1.18 : 1.0)
            .offset(y: index == 2 ? -8 : 0)
    }

    @ViewBuilder
    private func actionRow(primaryLabel: String) -> some View {
        HStack(spacing: 12) {
            Button(action: onHome) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill").font(.system(size: 18))
                    Text("Home").font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundColor(.sunnyInk)
                .frame(height: 70)
                .padding(.horizontal, 22)
                .background(Color.sunnyPaper)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.sunnyRule, lineWidth: 1.5))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color(hex: "E0D4A6"), radius: 0, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            Button(action: onPlayAgain) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill").font(.system(size: 20))
                    Text(primaryLabel).font(.system(size: 22, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.sunnyLemon)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.sunnyInk)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black, radius: 0, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ResultsView(p1Score: 7, p2Score: 0, players: 1, onPlayAgain: {}, onHome: {})
}
