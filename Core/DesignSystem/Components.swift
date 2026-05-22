import SwiftUI

// MARK: - BigButton

struct BigButton: View {
    let label: String
    let tone: ButtonTone
    var sfIcon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = sfIcon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                Text(label)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundColor(tone.fg)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
        }
        .buttonStyle(SunnyButtonStyle(tone: tone))
    }
}

struct SunnyButtonStyle: ButtonStyle {
    let tone: ButtonTone

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(tone.bg)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: tone.shadow, radius: 0, x: 0, y: configuration.isPressed ? 2 : 5)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - FlowLayout (wrapping row of chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > width && x > 0 { y += rowH + spacing; x = 0; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX && x > bounds.minX { y += rowH + spacing; x = bounds.minX; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}

// MARK: - CornerShape (camera HUD bracket corners)

struct CornerShape: Shape {
    var tl, tr, bl, br: Bool

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r: CGFloat = 10
        if tl {
            p.move(to: CGPoint(x: rect.minX, y: rect.minY + r))
            p.addLine(to: .init(x: rect.minX, y: rect.minY))
            p.addLine(to: .init(x: rect.minX + r, y: rect.minY))
        }
        if tr {
            p.move(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX, y: rect.minY + r))
        }
        if bl {
            p.move(to: CGPoint(x: rect.minX, y: rect.maxY - r))
            p.addLine(to: .init(x: rect.minX, y: rect.maxY))
            p.addLine(to: .init(x: rect.minX + r, y: rect.maxY))
        }
        if br {
            p.move(to: CGPoint(x: rect.maxX - r, y: rect.maxY - r))
            p.addLine(to: .init(x: rect.maxX, y: rect.maxY))
            p.addLine(to: .init(x: rect.maxX - r, y: rect.maxY))
        }
        return p
    }
}
