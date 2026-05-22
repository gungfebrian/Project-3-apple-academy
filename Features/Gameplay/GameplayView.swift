import SwiftUI
import Combine

struct GameplayView: View {
    let difficulty: Difficulty
    let duration: Int
    let lang: GameLang
    let onFinish: (Int, [String], [String]) -> Void
    let onExit: () -> Void

    @State private var words: [FallingWord] = []
    @State private var countdown: Int = 3
    @State private var started = false
    @State private var paused = false
    @State private var timeLeft: Int
    @State private var score = 0
    @State private var missedCount = 0
    @State private var caughtList: [String] = []
    @State private var missedList: [String] = []
    @State private var poppers: [WordPopper] = []
    @State private var lastTick = Date()
    @State private var spawnAccum = 0.0
    @State private var clockAccum = 0.0
    @State private var stageSize: CGSize = .zero

    private let physicsTimer = Timer.publish(every: 1 / 30.0, on: .main, in: .common).autoconnect()

    init(difficulty: Difficulty, duration: Int, lang: GameLang,
         onFinish: @escaping (Int, [String], [String]) -> Void,
         onExit: @escaping () -> Void) {
        self.difficulty = difficulty
        self.duration = duration
        self.lang = lang
        self.onFinish = onFinish
        self.onExit = onExit
        _timeLeft = State(initialValue: duration)
    }

    var body: some View {
        ZStack {
            skyBackground.ignoresSafeArea()

            // Capture stage size
            GeometryReader { geo in
                Color.clear
                    .onAppear { stageSize = geo.size }
                    .onChange(of: geo.size) { _, newSize in stageSize = newSize }
            }
            .ignoresSafeArea()

            hudCorners
            ForEach(words) { w in wordChip(w) }

            VStack(spacing: 0) {
                topHUD.padding(.horizontal, 14).padding(.top, 52)
                progressBar.padding(.horizontal, 14).padding(.top, 8)
                if started && !paused { listenHint.padding(.top, 10) }
                Spacer()
            }

            ForEach(poppers) { p in
                Text("+1 \"\(p.text)\"")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.sunnyGreen)
                    .opacity(p.opacity)
                    .offset(y: p.yOffset)
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
            onFinish(score, caughtList, missedList)
            return
        }

        spawnAccum += dt
        if spawnAccum >= difficulty.spawnInterval {
            spawnAccum = 0
            spawnWord()
        }

        let h = stageSize.height
        var newMissed: [String] = []
        words = words.compactMap { w in
            var u = w; u.y += CGFloat(w.vy * dt)
            if u.y > h + 40 { newMissed.append(w.text); return nil }
            return u
        }
        if !newMissed.isEmpty {
            missedCount += newMissed.count
            missedList.append(contentsOf: newMissed)
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
        score += 1
        caughtList.append(word.text)
        let p = WordPopper(text: word.text)
        poppers.append(p)
        withAnimation(.easeOut(duration: 0.8)) {
            if let i = poppers.firstIndex(where: { $0.id == p.id }) {
                poppers[i].yOffset = -80
                poppers[i].opacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            poppers.removeAll { $0.id == p.id }
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

    private var hudCorners: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let pad: CGFloat = 14, len: CGFloat = 26, thick: CGFloat = 3
            let c = Color.white.opacity(0.85)
            ZStack {
                CornerShape(tl: true,  tr: false, bl: false, br: false).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: pad + len/2, y: 100 + len/2)
                CornerShape(tl: false, tr: true,  bl: false, br: false).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: w - pad - len/2, y: 100 + len/2)
                CornerShape(tl: false, tr: false, bl: true,  br: false).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: pad + len/2, y: h - 100 - len/2)
                CornerShape(tl: false, tr: false, bl: false, br: true).stroke(c, lineWidth: thick)
                    .frame(width: len, height: len).position(x: w - pad - len/2, y: h - 100 - len/2)
            }
        }
        .allowsHitTesting(false)
    }

    private var topHUD: some View {
        HStack(spacing: 10) {
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

            HStack(spacing: 0) {
                hudStat(label: "TIME",  value: "0:\(String(format: "%02d", timeLeft))")
                divider
                hudStat(label: "SCORE", value: "\(score)",       accent: true)
                divider
                hudStat(label: "MISS",  value: "\(missedCount)", warn: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.black.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var divider: some View {
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
    GameplayView(difficulty: .gentle, duration: 60, lang: .english,
                 onFinish: { _, _, _ in }, onExit: {})
}
