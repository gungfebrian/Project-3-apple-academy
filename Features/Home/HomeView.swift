import SwiftUI

struct HomeView: View {
    let onPlay: (String) -> Void

    @State private var tab: AppTab = .home

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning" }
        if h < 18 { return "Good afternoon" }
        return "Good evening"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sunnyBg.ignoresSafeArea()

            // Warm radial gradients (matches prototype background)
            ZStack {
                RadialGradient(colors: [Color(hex: "FFE9A8"), .clear],
                               center: .topLeading, startRadius: 0, endRadius: 300)
                    .opacity(0.7)
                RadialGradient(colors: [Color(hex: "FFD9CB"), .clear],
                               center: .bottomTrailing, startRadius: 0, endRadius: 350)
                    .opacity(0.6)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    greetingRow
                    streakStrip.padding(.top, 18)
                    heroCard.padding(.top, 22)
                    moreGamesHeader.padding(.top, 28)
                    gameGrid.padding(.top, 14)
                    familyCTA.padding(.top, 22)
                    Spacer().frame(height: 110)
                }
                .padding(.horizontal, 22)
            }

            floatingTabBar.padding(.bottom, 18)
        }
    }

    // MARK: Greeting

    private var greetingRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting + ",")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.sunnyInk2)
                Text("Grandma Eli")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.sunnyYellow, .sunnyCoral],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                    .shadow(color: Color(hex: "C9A41A"), radius: 0, x: 0, y: 4)
                Text("👵").font(.system(size: 26))
            }
        }
        .padding(.top, 14)
    }

    // MARK: Streak Strip

    private var streakStrip: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.sunnyLemon)
                .frame(width: 44, height: 44)
                .overlay(Text("🔥").font(.system(size: 22)))
            VStack(alignment: .leading, spacing: 2) {
                Text("5-day streak")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk)
                Text("Keep it going — play once today")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.sunnyInk2)
            }
            Spacer()
            HStack(spacing: 4) {
                ForEach(1...7, id: \.self) { i in
                    Circle()
                        .fill(i <= 5 ? Color.sunnyYel2 : Color.sunnyRule)
                        .frame(width: 10, height: 10)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.sunnyRule, lineWidth: 1.5))
    }

    // MARK: Hero Card

    private var heroCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.sunnyLemon)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color(hex: "F0C824"), lineWidth: 1.5))
                .shadow(color: Color(hex: "E2B61A").opacity(0.35), radius: 22, x: 0, y: 8)

            Text("☁️")
                .font(.system(size: 110))
                .opacity(0.3)
                .rotationEffect(.degrees(15))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 20, y: -28)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                Text("TODAY'S CHALLENGE")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyLemon)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.sunnyInk)
                    .clipShape(Capsule())

                Text("Catch the Words\nfrom the sky")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.sunnyInk)
                    .lineSpacing(2)
                    .padding(.top, 10)

                Text("Use your camera. Reach out and grab the falling words.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.sunnyInk2)
                    .padding(.top, 8)
                    .frame(maxWidth: 260, alignment: .leading)

                Button { onPlay("catch") } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill").font(.system(size: 16, weight: .bold))
                        Text("Let's play")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.sunnyLemon)
                    .padding(.horizontal, 22).padding(.vertical, 12)
                    .background(Color.sunnyInk)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.35), radius: 0, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
            }
            .padding(22)
        }
    }

    // MARK: More Games

    private var moreGamesHeader: some View {
        HStack {
            Text("More games")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.sunnyInk)
            Spacer()
            Text("See all")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.sunnyInk3)
        }
    }

    private var gameGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            gameCard("Mirror Me",       sub: "Camera • 2 min",   tone: .coral, emoji: "👄", tilt: -0.6, game: "mirror")
            gameCard("Family Charades", sub: "2+ players",        tone: .teal,  emoji: "🎭", tilt:  0.6, game: "charades")
            gameCard("Word Hunt",       sub: "Point your camera", tone: .cream, emoji: "🔍", tilt: -0.6, game: "hunt")
        }
    }

    private func gameCard(_ title: String, sub: String, tone: CardTone,
                          emoji: String, tilt: Double, game: String) -> some View {
        Button { onPlay(game) } label: {
            VStack(alignment: .leading) {
                Text(emoji).font(.system(size: 38))
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(tone == .ink ? Color.sunnyBg : .sunnyInk)
                    Text(sub)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(tone == .ink ? Color.sunnyInk3 : .sunnyInk2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .frame(minHeight: 150)
            .background(tone.bg)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(tone.border, lineWidth: 1.5))
            .rotationEffect(.degrees(tilt))
            .shadow(color: Color.sunnyInk.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: Family CTA

    private var familyCTA: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.sunnyYellow)
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: "phone.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.sunnyInk))
            VStack(alignment: .leading, spacing: 2) {
                Text("Play with Maya")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "FFF6E0"))
                Text("Your granddaughter is online")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color(hex: "C9C2A8"))
            }
            Spacer()
            Text("Call")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.sunnyInk)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color.sunnyYellow)
                .clipShape(Capsule())
        }
        .padding(20)
        .background(Color(hex: "1F1B16"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: Tab Bar

    private var floatingTabBar: some View {
        HStack(spacing: 4) {
            tabItem(.home,   label: "Play",   icon: "house.fill")
            tabItem(.streak, label: "Streak", icon: "flame.fill")
            tabItem(.family, label: "Family", icon: "person.2.fill")
            tabItem(.me,     label: "Me",     icon: "person.fill")
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .background(Color.sunnyPaper.opacity(0.55))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.sunnyRule, lineWidth: 1.5))
        .shadow(color: Color.sunnyInk.opacity(0.12), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 18)
    }

    private func tabItem(_ t: AppTab, label: String, icon: String) -> some View {
        Button { tab = t } label: {
            VStack(spacing: 2) {
                Image(systemName: icon).font(.system(size: 22, weight: .semibold))
                Text(label).font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundColor(tab == t ? .sunnyLemon : .sunnyInk)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(tab == t ? Color.sunnyInk : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview { HomeView { _ in } }
