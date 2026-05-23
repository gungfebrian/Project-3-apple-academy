import SwiftUI

struct HomeView: View {
    let onSelect: (Int) -> Void

    private struct Mode {
        let title: String
        let sub: String
        let tone: CardTone
        let icon: String
        let players: Int
        let tilt: Double
    }

    private let modes: [Mode] = [
        Mode(title: "1 Player",  sub: "Solo practice",        tone: .yellow, icon: "👤", players: 1, tilt: -0.6),
        Mode(title: "2 Players", sub: "Face-off · same room", tone: .coral,  icon: "👥", players: 2, tilt:  0.6),
        Mode(title: "Family",    sub: "Call grandkids",       tone: .teal,   icon: "📞", players: 2, tilt: -0.6),
    ]

    var body: some View {
        ZStack {
            // Paper background with warm gradients
            Color.sunnyBg.ignoresSafeArea()
            ZStack {
                RadialGradient(colors: [Color(hex: "FFE9A8"), .clear],
                               center: .topLeading, startRadius: 0, endRadius: 350)
                    .opacity(0.65)
                RadialGradient(colors: [Color(hex: "FFD9CB"), .clear],
                               center: .bottomTrailing, startRadius: 0, endRadius: 400)
                    .opacity(0.55)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Faint silhouettes background
            silhouettesBg.ignoresSafeArea().allowsHitTesting(false)

            // Static ambient word cloud
            wordCloud.allowsHitTesting(false)

            // Layout
            VStack(spacing: 0) {
                headerBar
                    .padding(.top, 16)
                    .padding(.trailing, 22)

                HStack(alignment: .center, spacing: 22) {
                    titleBlock
                        .frame(maxWidth: .infinity, alignment: .leading)
                    modeCardStack
                        .frame(maxWidth: .infinity)
                }
                .padding(.trailing, 22)
                .frame(maxHeight: .infinity)

                cameraHint
                    .padding(.bottom, 14)
                    .padding(.trailing, 22)
            }
        }
    }

    // MARK: - Background silhouettes

    private var silhouettesBg: some View {
        Canvas { ctx, size in
            ctx.opacity = 0.06
            let w = size.width, h = size.height

            // Person 1 (left)
            let h1x = w * 0.30, h1y = h * 0.72, hr: CGFloat = 55
            ctx.fill(Path(ellipseIn: CGRect(x: h1x - hr, y: h1y - hr, width: hr * 2, height: hr * 2)),
                     with: .color(.sunnyInk))
            var b1 = Path()
            b1.move(to: CGPoint(x: h1x - 80, y: h))
            b1.addCurve(to: CGPoint(x: h1x, y: h1y + hr),
                        control1: CGPoint(x: h1x - 80, y: h - 50),
                        control2: CGPoint(x: h1x - 30, y: h1y + hr))
            b1.addCurve(to: CGPoint(x: h1x + 80, y: h),
                        control1: CGPoint(x: h1x + 30, y: h1y + hr),
                        control2: CGPoint(x: h1x + 80, y: h - 50))
            b1.closeSubpath()
            ctx.fill(b1, with: .color(.sunnyInk))

            // Person 2 (right)
            let h2x = w * 0.70
            ctx.fill(Path(ellipseIn: CGRect(x: h2x - hr, y: h1y - hr, width: hr * 2, height: hr * 2)),
                     with: .color(.sunnyInk))
            var b2 = Path()
            b2.move(to: CGPoint(x: h2x - 80, y: h))
            b2.addCurve(to: CGPoint(x: h2x, y: h1y + hr),
                        control1: CGPoint(x: h2x - 80, y: h - 50),
                        control2: CGPoint(x: h2x - 30, y: h1y + hr))
            b2.addCurve(to: CGPoint(x: h2x + 80, y: h),
                        control1: CGPoint(x: h2x + 30, y: h1y + hr),
                        control2: CGPoint(x: h2x + 80, y: h - 50))
            b2.closeSubpath()
            ctx.fill(b2, with: .color(.sunnyInk))
        }
    }

    // MARK: - Floating word cloud (static, ambient)

    private let ambientWords = ["cloud", "laugh", "window", "tea", "garden",
                                "smile", "memory", "sunshine", "umbrella", "blanket"]
    private var wordCloud: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ForEach(Array(ambientWords.enumerated()), id: \.offset) { idx, word in
                let xFrac = Double(6 + (idx * 73) % 88) / 100.0
                let yFrac = Double(15 + (idx * 47) % 70) / 100.0
                let rot   = Double((idx * 31) % 12) - 6.0
                let size  = CGFloat(14 + idx % 4 * 3)
                let opa   = 0.09 + Double(idx % 3) * 0.04
                Text(word)
                    .font(.system(size: size, weight: .bold, design: .rounded))
                    .foregroundColor(.sunnyInk)
                    .opacity(opa)
                    .rotationEffect(.degrees(rot))
                    .position(x: xFrac * w, y: yFrac * h)
            }
        }
    }

    // MARK: - Header bar

    private var headerBar: some View {
        HStack {
            // Sun wordmark (respects left safe area)
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.sunnyYellow, .sunnyCoral],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("☀").font(.system(size: 14))
                }
                .frame(width: 28, height: 28)
                .shadow(color: Color(hex: "C9A41A"), radius: 0, x: 0, y: 2)

                Text("Sunny")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.sunnyInk)
            }

            Spacer()

            // Streak + gear
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Text("🔥").font(.system(size: 14))
                    Text("5")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.sunnyInk)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.sunnyPaper)
                .overlay(Capsule().stroke(Color.sunnyRule, lineWidth: 1.5))
                .clipShape(Capsule())

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.sunnyPaper)
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.sunnyRule, lineWidth: 1.5))
                    Image(systemName: "gearshape")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.sunnyInk2)
                }
                .frame(width: 38, height: 38)
            }
        }
    }

    // MARK: - Title block (left column)

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Party mode · 57+")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.sunnyLemon)
                .tracking(2)
                .padding(.horizontal, 12).padding(.vertical, 4)
                .background(Color.sunnyInk)
                .clipShape(Capsule())
                .rotationEffect(.degrees(-2))

            VStack(alignment: .leading, spacing: -4) {
                Text("Catch the")
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                Text("words!")
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.sunnyInk)
            .padding(.top, 14)

            Text("~ prop me up · step back · play ~")
                .font(.system(size: 20, weight: .medium).italic())
                .foregroundColor(.sunnyCoral)
                .rotationEffect(.degrees(-1.5))
                .padding(.top, 10)
        }
    }

    // MARK: - Mode card stack (right column)

    private var modeCardStack: some View {
        VStack(spacing: 10) {
            ForEach(modes.indices, id: \.self) { i in
                modeCard(modes[i])
            }
        }
    }

    private func modeCard(_ mode: Mode) -> some View {
        Button { onSelect(mode.players) } label: {
            HStack(spacing: 14) {
                // Emoji icon box
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.6))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.sunnyInk.opacity(0.08), lineWidth: 1.5))
                    Text(mode.icon).font(.system(size: 26))
                }
                .frame(width: 52, height: 52)
                .flexibleFlexibleItem(false)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.sunnyInk)
                    Text(mode.sub)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.sunnyInk2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Play arrow circle
                ZStack {
                    Circle().fill(Color.sunnyInk)
                    Image(systemName: "play.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.sunnyLemon)
                }
                .frame(width: 38, height: 38)
            }
            .padding(14)
            .background(mode.tone.bg)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(mode.tone.border, lineWidth: 1.5))
            .shadow(color: mode.tone.shadow, radius: 0, x: 0, y: 5)
            .rotationEffect(.degrees(mode.tilt))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom camera hint

    private var cameraHint: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.sunnyYellow)
                Image(systemName: "camera")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.sunnyInk)
            }
            .frame(width: 22, height: 22)

            Text("Camera will turn on when you start")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.sunnyInk2)
        }
    }
}

// Helper to avoid `.frame(maxWidth: .infinity)` on icon box
private extension View {
    func flexibleFlexibleItem(_ flexible: Bool) -> some View {
        self
    }
}

#Preview { HomeView { _ in } }
