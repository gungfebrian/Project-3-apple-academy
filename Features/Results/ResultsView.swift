import SwiftUI

struct ResultsView: View {
    let score: Int
    let caught: [String]
    let missed: [String]
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    private var stars: Int { score >= 8 ? 3 : score >= 5 ? 2 : 1 }

    var body: some View {
        ZStack {
            Color.sunnyBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    scoreCard.padding(.top, 14)
                    if !caught.isEmpty {
                        sectionLabel("YOU CAUGHT").padding(.top, 22)
                        caughtChips.padding(.top, 10)
                    }
                    if !missed.isEmpty {
                        sectionLabel("SLIPPED AWAY").padding(.top, 18)
                        missedChips.padding(.top, 10)
                    }
                    streakBanner.padding(.top, 22)
                    actions.padding(.top, 26).padding(.bottom, 40)
                }
                .padding(.horizontal, 22)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        Text("~ great catch! ~")
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .italic()
            .foregroundColor(.sunnyCoral)
            .rotationEffect(.degrees(-3))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 14)
    }

    // MARK: Score Card

    private var scoreCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.sunnyLemon)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color(hex: "F0C824"), lineWidth: 1.5))
                .shadow(color: Color(hex: "E2B61A").opacity(0.35), radius: 0, x: 0, y: 6)

            Text("🏆").font(.system(size: 60)).opacity(0.2).padding(16)

            VStack(alignment: .leading, spacing: 0) {
                Text("ROUND COMPLETE")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk2)
                    .tracking(2)

                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text("\(score)")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundColor(.sunnyInk)
                    Text("/ \(score + missed.count)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.sunnyInk2)
                }
                .padding(.top, 8)

                Text("words caught")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.sunnyInk2)

                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { i in
                        Text("⭐").font(.system(size: 32))
                            .opacity(i <= stars ? 1 : 0.25)
                            .grayscale(i <= stars ? 0 : 1)
                    }
                }
                .padding(.top, 14)
            }
            .padding(24)
        }
    }

    // MARK: Word Chips

    private var caughtChips: some View {
        FlowLayout(spacing: 8) {
            ForEach(caught.indices, id: \.self) { i in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.sunnyGreen)
                    Text(caught[i])
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.sunnyInk)
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color.sunnyPaper)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.sunnyRule, lineWidth: 1.5))
                .rotationEffect(.degrees(i.isMultiple(of: 2) ? -1.5 : 1.5))
            }
        }
    }

    private var missedChips: some View {
        FlowLayout(spacing: 8) {
            ForEach(missed, id: \.self) { w in
                Text(w)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.sunnyInk3)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .overlay(Capsule()
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .foregroundColor(.sunnyInk3))
            }
        }
    }

    // MARK: Streak Banner

    private var streakBanner: some View {
        HStack(spacing: 14) {
            Text("🔥").font(.system(size: 36))
            VStack(alignment: .leading, spacing: 2) {
                Text("Streak: 5 days")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk)
                Text("One more day to a week!")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.sunnyInk2)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(hex: "FFCFC1"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color(hex: "F0997D"), lineWidth: 1.5))
    }

    // MARK: Actions

    private var actions: some View {
        VStack(spacing: 12) {
            BigButton(label: "Play again", tone: .ink,   sfIcon: "play.fill",  action: onPlayAgain)
            BigButton(label: "Back home",  tone: .ghost, sfIcon: "house.fill", action: onHome)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.sunnyInk2)
            .tracking(1)
    }
}

#Preview {
    ResultsView(
        score: 7,
        caught: ["cloud", "sunshine", "window", "garden", "family", "tea", "photo"],
        missed: ["butterfly", "kettle"],
        onPlayAgain: {}, onHome: {}
    )
}
