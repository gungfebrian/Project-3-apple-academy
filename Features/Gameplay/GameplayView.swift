import SwiftUI
import Combine

// MARK: - Player silhouette (VS mode)

private struct PlayerSilhouette: View {
    let isLeft: Bool
    let color: Color
    let label: String

    var body: some View {
        ZStack(alignment: .top) {
            Canvas { ctx, size in
                let cx = size.width / 2

                // Glow halo
                ctx.opacity = 0.22
                ctx.fill(Path(ellipseIn: CGRect(x: cx - 52, y: 52, width: 104, height: 72)),
                         with: .color(color))
                ctx.opacity = 1.0

                // Head
                let headR: CGFloat = 22
                let headY: CGFloat = 10 + headR
                let headRect = CGRect(x: cx - headR, y: headY - headR, width: headR * 2, height: headR * 2)
                ctx.opacity = 0.5
                ctx.fill(Path(ellipseIn: headRect), with: .color(Color(hex: "1F1B16")))
                ctx.opacity = 0.7
                ctx.stroke(Path(ellipseIn: headRect), with: .color(.white), lineWidth: 2)

                // Body
                let bodyTopY = headY + headR + 3
                var bodyPath = Path()
                bodyPath.move(to: CGPoint(x: cx - 38, y: size.height))
                bodyPath.addCurve(to: CGPoint(x: cx, y: bodyTopY),
                                  control1: CGPoint(x: cx - 38, y: size.height - 54),
                                  control2: CGPoint(x: cx - 16, y: bodyTopY))
                bodyPath.addCurve(to: CGPoint(x: cx + 38, y: size.height),
                                  control1: CGPoint(x: cx + 16, y: bodyTopY),
                                  control2: CGPoint(x: cx + 38, y: size.height - 54))
                bodyPath.closeSubpath()
                ctx.opacity = 0.5
                ctx.fill(bodyPath, with: .color(Color(hex: "1F1B16")))
                ctx.opacity = 0.7
                ctx.stroke(bodyPath, with: .color(.white), lineWidth: 2)

                // Reaching arm (dashed)
                let shoulderX = isLeft ? cx + 22 : cx - 22
                let shoulderY = bodyTopY + 14
                let tipX: CGFloat = isLeft ? size.width - 8 : 8
                var arm = Path()
                arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
                arm.addCurve(to: CGPoint(x: tipX, y: 16),
                             control1: CGPoint(x: shoulderX + (isLeft ? 22 : -22), y: shoulderY - 26),
                             control2: CGPoint(x: tipX + (isLeft ? -14 : 14), y: 52))
                ctx.opacity = 0.7
                ctx.stroke(arm, with: .color(.white),
                           style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 4]))
                ctx.opacity = 1.0
            }

            // Label pill
            Text(label)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.sunnyInk)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(color)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 3)
                .frame(maxWidth: .infinity, alignment: isLeft ? .leading : .trailing)
                .padding(.top, 20)
                .padding(.horizontal, 4)
        }
        .frame(width: 120, height: 160)
    }
}

// MARK: - Gameplay View

struct GameplayView: View {
    let difficulty: Difficulty
    let duration: Int
    let lang: GameLang
    let players: Int
    let onFinish: (Int, Int) -> Void   // (p1Score, p2Score)
    let onExit: () -> Void

    @State private var words: [FallingWord] = []
    @State private var countdown: Int = 3
    @State private var started = false
    @State private var paused = false
    @State private var timeLeft: Int
    @State private var p1Score = 0
    @State private var p2Score = 0
    @State private var missedCount = 0
    @State private var poppers: [WordPopper] = []
    @State private var lastTick = Date()
    @State private var spawnAccum = 0.0
    @State private var clockAccum = 0.0
    @State private var stageSize: CGSize = .zero

    private var isVs: Bool { players == 2 }
    private let physicsTimer = Timer.publish(every: 1 / 30.0, on: .main, in: .common).autoconnect()

    init(difficulty: Difficulty, duration: Int, lang: GameLang, players: Int,
         onFinish: @escaping (Int, Int) -> Void,
         onExit: @escaping () -> Void) {
        self.difficulty = difficulty
        self.duration = duration
        self.lang = lang
        self.players = players
        self.onFinish = onFinish
        self.onExit = onExit
        _timeLeft = State(initialValue: duration)
    }

    var body: some View {
        ZStack {
            skyBackground.ignoresSafeArea()

            GeometryReader { geo in
                Color.clear
                    .onAppear { stageSize = geo.size }
                    .onChange(of: geo.size) { _, newSize in stageSize = newSize }
            }
            .ignoresSafeArea()

            hudCorners

            // VS extras
            if isVs {
                // Center dashed divider
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .overlay(
                            Path { p in
                                p.move(to: CGPoint(x: geo.size.width / 2, y: 90))
                                p.addLine(to: CGPoint(x: geo.size.width / 2, y: geo.size.height - 80))
                            }
                            .stroke(Color.white.opacity(0.55),
                                    style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                        )
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                // Player silhouettes
                GeometryReader { geo in
                    let h = geo.size.height, w = geo.size.width
                    PlayerSilhouette(isLeft: true,  color: Color(hex: "FFD84D"), label: "P1")
                        .position(x: w * 0.14, y: h - 90)
                    PlayerSilhouette(isLeft: false, color: Color(hex: "FF7A5A"), label: "P2")
                        .position(x: w * 0.86, y: h - 90)
                }
                .allowsHitTesting(false)
            }

            // Hand outline (solo only)
            if !isVs {
                handOutline.allowsHitTesting(false)
            }

            ForEach(words) { w in wordChip(w) }

            VStack(spacing: 0) {
                topHUD.padding(.horizontal, 14).padding(.top, 14)
                progressBar.padding(.horizontal, 14).padding(.top, 8)
                if started && !paused { listenHint.padding(.top, 10) }
                Spacer()
            }

            ForEach(poppers) { p in
                let xPos: CGFloat = isVs ? (p.isP2 ? 0.75 : 0.25) : 0.5
                GeometryReader { geo in
                    Text("+1 \"\(p.text)\"")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(p.isP2 ? .sunnyCoral : .sunnyGreen)
                        .opacity(p.opacity)
                        .offset(y: p.yOffset)
                        .position(x: geo.size.width * xPos, y: geo.size.height * 0.38)
                        .allowsHitTesting(false)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }

            if !started { countdownOverlay }
            if paused && started { pauseOverlay }
        }
        .ignoresSafeArea()
        .onReceive(physicsTimer) { now in
            guard started && !paused else { lastTick = now; return }
            let dt = min(0.1, now.timeIntervalSince(lastTick))
            lastTick = now
            tick(dt: dt)
        }
        .task { await runCountdown() }
    }

    // MARK: - Game Logic

    private func runCountdown() async {
        for i in stride(from: 3, through: 1, by: -1) {
            countdown = i
            try? await Task.sleep(nanoseconds: 800_000_000)
        }
        countdown = 0
        try? await Task.sleep(nanoseconds: 600_000_000)
        started = true
        lastTick = Date()
    }

    private func tick(dt: Double) {
        clockAccum += dt
        if clockAccum >= 1.0 {
            clockAccum -= 1.0
            timeLeft = max(0, timeLeft - 1)
        }
        if timeLeft <= 0 {
            onFinish(p1Score, p2Score)
            return
        }

        spawnAccum += dt
        if spawnAccum >= difficulty.spawnInterval {
            spawnAccum = 0
            spawnWord()
        }

        let h = stageSize.height
        words = words.compactMap { w in
            var u = w; u.y += CGFloat(w.vy * dt)
            if u.y > h + 40 { missedCount += 1; return nil }
            return u
        }
    }

    private func spawnWord() {
        let text = lang.wordBank.randomElement() ?? "word"
        let margin: CGFloat = 70
        let x = CGFloat.random(in: margin...(max(margin * 2, stageSize.width - margin)))
        let vy = CGFloat((40 + Double.random(in: 0...30)) * difficulty.speedMult)
        let tones = ChipTone.allCases
        words.append(FallingWord(
            text: text, x: x, y: -40, vy: vy,
            rotation: Double.random(in: -6...6),
            chipTone: tones[Int.random(in: 0..<tones.count)]
        ))
    }

    private func catchWord(_ word: FallingWord) {
        words.removeAll { $0.id == word.id }
        let isP2 = isVs && word.x > stageSize.width / 2
        if isP2 { p2Score += 1 } else { p1Score += 1 }

        let popper = WordPopper(text: word.text, isP2: isP2)
        poppers.append(popper)
        withAnimation(.easeOut(duration: 0.8)) {
            if let i = poppers.firstIndex(where: { $0.id == popper.id }) {
                poppers[i].yOffset = -80
                poppers[i].opacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            poppers.removeAll { $0.id == popper.id }
        }
    }

    // MARK: - Subviews

    private var skyBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "BBD9E8"), Color(hex: "C8E5D8"), Color(hex: "ECDDB6")],
                startPoint: .top, endPoint: .bottom
            )
            ZStack {
                Ellipse().fill(Color.white.opacity(0.65)).frame(width: 130, height: 34).offset(x: -70, y: -300)
                Ellipse().fill(Color.white.opacity(0.5)).frame(width: 170, height: 38).offset(x: 60, y: -260)
                Ellipse().fill(Color.white.opacity(0.55)).frame(width: 145, height: 30).offset(x: -20, y: -320)
            }
            RadialGradient(
                colors: [Color(hex: "FFE896").opacity(0.85), Color(hex: "FFC85A").opacity(0.25), .clear],
                center: .center, startRadius: 0, endRadius: 100
            )
            .frame(width: 200, height: 200).offset(x: 80, y: -160)
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, Color(hex: "A07846").opacity(0.18), Color(hex: "5A4628").opacity(0.3)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 280)
            }
        }
    }

    private var handOutline: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height - 110
            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1F1B16").opacity(0.5), .clear],
                            center: .center, startRadius: 0, endRadius: 90
                        )
                    )
                    .frame(width: 200, height: 160)
                    .blur(radius: 5)
                    .position(x: cx, y: cy + 10)

                Canvas { ctx, _ in
                    var hand = Path()
                    let ox = cx - 60, oy: CGFloat = cy - 40
                    hand.move(to: CGPoint(x: ox + 30, y: oy + 90))
                    hand.addCurve(to: CGPoint(x: ox + 25, y: oy + 60),
                                  control1: CGPoint(x: ox + 20, y: oy + 75),
                                  control2: CGPoint(x: ox + 22, y: oy + 62))
                    hand.addCurve(to: CGPoint(x: ox + 35, y: oy + 28),
                                  control1: CGPoint(x: ox + 30, y: oy + 40),
                                  control2: CGPoint(x: ox + 35, y: oy + 28))
                    hand.addCurve(to: CGPoint(x: ox + 52, y: oy + 30),
                                  control1: CGPoint(x: ox + 50, y: oy + 18),
                                  control2: CGPoint(x: ox + 52, y: oy + 22))
                    hand.addCurve(to: CGPoint(x: ox + 73, y: oy + 38),
                                  control1: CGPoint(x: ox + 65, y: oy + 22),
                                  control2: CGPoint(x: ox + 70, y: oy + 28))
                    hand.addCurve(to: CGPoint(x: ox + 90, y: oy + 55),
                                  control1: CGPoint(x: ox + 90, y: oy + 45),
                                  control2: CGPoint(x: ox + 92, y: oy + 48))
                    hand.addCurve(to: CGPoint(x: ox + 100, y: oy + 95),
                                  control1: CGPoint(x: ox + 96, y: oy + 65),
                                  control2: CGPoint(x: ox + 100, y: oy + 80))
                    hand.addCurve(to: CGPoint(x: ox + 55, y: oy + 128),
                                  control1: CGPoint(x: ox + 95, y: oy + 115),
                                  control2: CGPoint(x: ox + 70, y: oy + 128))
                    hand.addCurve(to: CGPoint(x: ox + 30, y: oy + 90),
                                  control1: CGPoint(x: ox + 40, y: oy + 128),
                                  control2: CGPoint(x: ox + 32, y: oy + 110))
                    ctx.stroke(hand, with: .color(.white.opacity(0.8)),
                               style: StrokeStyle(lineWidth: 2.2, lineCap: .round, dash: [6, 4]))
                }
            }
        }
    }

    private var hudCorners: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let pad: CGFloat = 14, len: CGFloat = 26, thick: CGFloat = 3
            let c = Color.white.opacity(0.85)
            ZStack {
                CornerShape(tl: true,  tr: false, bl: false, br: false).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: pad + len/2, y: 90 + len/2)
                CornerShape(tl: false, tr: true,  bl: false, br: false).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: w - pad - len/2, y: 90 + len/2)
                CornerShape(tl: false, tr: false, bl: true,  br: false).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: pad + len/2, y: h - 90 - len/2)
                CornerShape(tl: false, tr: false, bl: false, br: true).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: w - pad - len/2, y: h - 90 - len/2)
            }
        }
        .allowsHitTesting(false)
    }

    private var topHUD: some View {
        HStack(spacing: 10) {
            // Pause button
            Button {
                paused.toggle()
                if !paused { lastTick = Date() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.65))
                    Image(systemName: paused ? "play.fill" : "pause.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.sunnyLemon)
                }
                .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

            // Stats pill
            Group {
                if isVs {
                    vsStatsPill
                } else {
                    soloStatsPill
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.black.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var soloStatsPill: some View {
        HStack(spacing: 0) {
            hudStat(label: "TIME",  value: "0:\(String(format: "%02d", timeLeft))")
            statDivider
            hudStat(label: "SCORE", value: "\(p1Score)",     accent: true)
            statDivider
            hudStat(label: "MISS",  value: "\(missedCount)", warn: true)
        }
    }

    private var vsStatsPill: some View {
        HStack {
            // P1 (left, yellow)
            HStack(spacing: 6) {
                Circle().fill(Color(hex: "FFD84D")).frame(width: 10, height: 10)
                VStack(spacing: 0) {
                    Text("P1").font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                    Text("\(p1Score)").font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "FFD84D"))
                        .lineLimit(1)
                }
            }
            Spacer()
            // Time (center)
            VStack(spacing: 0) {
                Text("TIME").font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.7))
                Text("0:\(String(format: "%02d", timeLeft))")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "FFF6E0"))
            }
            Spacer()
            // P2 (right, coral)
            HStack(spacing: 6) {
                VStack(spacing: 0) {
                    Text("P2").font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                    Text("\(p2Score)").font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "FF9F8A"))
                        .lineLimit(1)
                }
                Circle().fill(Color(hex: "FF7A5A")).frame(width: 10, height: 10)
            }
        }
    }

    private var statDivider: some View {
        Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 30).padding(.horizontal, 8)
    }

    private func hudStat(label: String, value: String, accent: Bool = false, warn: Bool = false) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.7))
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(warn ? Color(hex: "FF9F8A") : accent ? .sunnyLemon : Color(hex: "FFF6E0"))
        }
        .frame(maxWidth: .infinity)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.2)).frame(height: 4)
                Capsule()
                    .fill(timeLeft < 10 ? Color.sunnyCoral : Color.sunnyLemon)
                    .frame(width: geo.size.width * CGFloat(timeLeft) / CGFloat(max(1, duration)), height: 4)
                    .animation(.linear(duration: 1), value: timeLeft)
            }
        }
        .frame(height: 4)
    }

    private var listenHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "mic.fill").font(.system(size: 13))
            Text("Listening — say the word or tap it")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.sunnyLemon)
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Color.black.opacity(0.65))
        .clipShape(Capsule())
    }

    private func wordChip(_ w: FallingWord) -> some View {
        Button { catchWord(w) } label: {
            Text(w.text)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.sunnyInk)
                .padding(.horizontal, 18).padding(.vertical, 12)
                .background(w.chipTone.bg)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(w.chipTone.border, lineWidth: 2))
                .shadow(color: w.chipTone.shadow, radius: 0, x: 0, y: 4)
                .rotationEffect(.degrees(w.rotation))
        }
        .buttonStyle(.plain)
        .position(x: w.x, y: w.y)
    }

    private var countdownOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("GET READY")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.sunnyLemon.opacity(0.9))
                    .tracking(2)
                Text(countdown > 0 ? "\(countdown)" : "GO!")
                    .font(.system(size: 140, weight: .heavy, design: .rounded))
                    .foregroundColor(.sunnyLemon)
                    .shadow(color: Color(hex: "C9A41A"), radius: 0, x: 0, y: 6)
                    .id(countdown)
                    .transition(.scale(scale: 1.4).combined(with: .opacity))
                    .animation(.easeOut(duration: 0.3), value: countdown)
                Text("Reach your hand into view")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.85))
            }
        }
        .allowsHitTesting(false)
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Paused")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.sunnyLemon)
                Text("Take your time.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(.top, 6)
                VStack(spacing: 12) {
                    BigButton(label: "Resume", tone: .yellow, sfIcon: "play.fill") {
                        paused = false; lastTick = Date()
                    }
                    BigButton(label: "Exit", tone: .ghost, sfIcon: "house.fill", action: onExit)
                }
                .frame(maxWidth: 260)
                .padding(.top, 28)
            }
        }
    }
}

#Preview {
    GameplayView(difficulty: .gentle, duration: 60, lang: .english, players: 1,
                 onFinish: { _, _ in }, onExit: {})
}
