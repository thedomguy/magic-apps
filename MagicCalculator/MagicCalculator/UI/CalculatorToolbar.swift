import SwiftUI

struct CalculatorToolbar: View {
    @Binding var mode: CalculatorMode
    let onHistory: () -> Void

    var body: some View {
        HStack {
            toolbarControl(
                systemName: "clock",
                accessibilityLabel: "History",
                action: onHistory
            )

            Spacer()

            Menu {
                Picker("Mode", selection: $mode) {
                    ForEach(CalculatorMode.primaryModes) { item in
                        Label(item.title, systemImage: item.systemImage)
                            .tag(item)
                    }

                    Section {
                        Label(
                            CalculatorMode.convert.title,
                            systemImage: CalculatorMode.convert.systemImage
                        )
                        .tag(CalculatorMode.convert)
                    }
                }
            } label: {
                CalculatorGlyph()
                    .fill(CalculatorTheme.toolbarIcon, style: FillStyle(eoFill: true))
                    .frame(width: 15.4, height: 21.7)
                    .frame(
                        width: CalculatorTheme.toolbarButtonSize,
                        height: CalculatorTheme.toolbarButtonSize
                    )
                    .modifier(ToolbarGlassChrome())
            }
            .accessibilityLabel("Calculator mode")
        }
        .padding(.horizontal, CalculatorTheme.sideMargin)
        .padding(.top, CalculatorTheme.toolbarTopPadding)
    }

    private func toolbarControl(
        systemName: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: CalculatorTheme.toolbarIconSize, weight: .regular))
                .foregroundStyle(CalculatorTheme.toolbarIcon)
                .frame(
                    width: CalculatorTheme.toolbarButtonSize,
                    height: CalculatorTheme.toolbarButtonSize
                )
                .modifier(ToolbarGlassChrome())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct ToolbarGlassChrome: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular.interactive(), in: .circle)
        } else {
            content.background {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    }
            }
        }
    }
}

/// Stock mode-button glyph (a pocket calculator); not a public SF Symbol, so traced from the
/// stock screenshot: 15.4×21.7 pt body, 1.8 pt display inset, 3×3 keys of 3 pt on a 4.25 pt pitch.
private struct CalculatorGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width / 15.4
        let h = rect.height / 21.7
        var path = Path(roundedRect: rect, cornerRadius: 2.4 * w, style: .continuous)
        path.addRoundedRect(
            in: CGRect(x: rect.minX + 1.8 * w, y: rect.minY + 1.7 * h, width: 11.8 * w, height: 5.2 * h),
            cornerSize: CGSize(width: 1.2 * w, height: 1.2 * w),
            style: .continuous
        )
        let diameter = 3.0 * w
        for row in 0..<3 {
            for column in 0..<3 {
                let center = CGPoint(
                    x: rect.minX + (3.45 + 4.25 * CGFloat(column)) * w,
                    y: rect.minY + (10.0 + 4.25 * CGFloat(row)) * h
                )
                path.addEllipse(in: CGRect(
                    x: center.x - diameter / 2,
                    y: center.y - diameter / 2,
                    width: diameter,
                    height: diameter
                ))
            }
        }
        return path
    }
}
