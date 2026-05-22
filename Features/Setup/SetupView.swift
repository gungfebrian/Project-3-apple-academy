import SwiftUI

struct SetupView: View {
    let game: String
    let onBack: () -> Void
    let onStart: (Difficulty, Int, GameLang) -> Void

    @State private var difficulty: Difficulty = .gentle
    @State private var duration: Int = 60
    @State private var lang: GameLang = .english

    var body: some View {
        ZStack {
            Color.sunnyBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    topBar
                    gameCard.padding(.top, 20)
                    sectionLabel("HOW FAST?").padding(.top, 26)
                    difficultyPicker.padding(.top, 10)
                    sectionLabel("LANGUAGE").padding(.top, 22)
                    languagePicker.padding(.top, 10)
                    sectionLabel("ROUND LENGTH").padding(.top, 22)
                    durationPicker.padding(.top, 10)
                    BigButton(label: "Start playing", tone: .ink, sfIcon: "play.fill") {
                        onStart(difficulty, duration, lang)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 22)
            }
        }
    }

    // MARK: Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.sunnyInk)
                    .frame(width: 52, height: 52)
                    .background(Color.sunnyPaper)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.sunnyRule, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "speaker.wave.2").font(.system(size: 14))
                Text("Voice on")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.sunnyInk)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.sunnyPaper)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.sunnyRule, lineWidth: 1.5))
        }
        .padding(.top, 14)
    }

    // MARK: Game Card

    private var gameCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.sunnyLemon)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color(hex: "F0C824"), lineWidth: 1.5))
                .shadow(color: Color(hex: "E2B61A").opacity(0.35), radius: 0, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 14) {
                Text("HOW TO PLAY")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk2)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("Catch the Words")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.sunnyInk)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach([
                        ("1", "Words will fall from the top of the screen."),
                        ("2", "Reach your hand into the camera view."),
                        ("3", "Say the word and grab it before it drops."),
                    ], id: \.0) { num, txt in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle().fill(Color.sunnyInk).frame(width: 28, height: 28)
                                Text(num)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.sunnyLemon)
                            }
                            Text(txt)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.sunnyInk)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(26)
        }
    }

    // MARK: Pickers

    private var difficultyPicker: some View {
        HStack(spacing: 10) {
            ForEach(Difficulty.allCases, id: \.self) { d in
                let sel = difficulty == d
                Button { difficulty = d } label: {
                    VStack(spacing: 4) {
                        Text(d.emoji).font(.system(size: 24))
                        Text(d.label)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Text(d.sub)
                            .font(.system(size: 11, design: .rounded))
                            .opacity(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(sel ? .sunnyLemon : .sunnyInk)
                    .background(sel ? Color.sunnyInk : Color.sunnyPaper)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(sel ? Color.sunnyInk : Color.sunnyRule, lineWidth: 1.5))
                    .shadow(color: sel ? .black.opacity(0.25) : Color.sunnyRule,
                            radius: 0, x: 0, y: sel ? 4 : 3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var languagePicker: some View {
        HStack(spacing: 0) {
            ForEach(GameLang.allCases, id: \.self) { l in
                let sel = lang == l
                Button { lang = l } label: {
                    HStack(spacing: 8) {
                        Text(l.flag).font(.system(size: 20))
                        Text(l.label)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(sel ? .sunnyLemon : .sunnyInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(sel ? Color.sunnyInk : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color.sunnyPaper)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.sunnyRule, lineWidth: 1.5))
    }

    private var durationPicker: some View {
        HStack(spacing: 10) {
            ForEach([30, 60, 90], id: \.self) { s in
                let sel = duration == s
                Button { duration = s } label: {
                    Text("\(s)s")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .foregroundColor(sel ? .white : .sunnyInk)
                        .background(sel ? Color.sunnyCoral : Color.sunnyPaper)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(sel ? Color.sunnyCoral : Color.sunnyRule, lineWidth: 1.5))
                        .shadow(color: sel ? Color(hex: "C84A2E") : Color.sunnyRule,
                                radius: 0, x: 0, y: sel ? 4 : 3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.sunnyInk2)
    }
}

#Preview { SetupView(game: "catch", onBack: {}, onStart: { _, _, _ in }) }
