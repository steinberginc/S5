import SwiftUI
import UIKit

enum S5Theme {
    static let black = Color(red: 0.02, green: 0.02, blue: 0.02)
    static let panel = Color(red: 0.07, green: 0.07, blue: 0.07)
    static let raised = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let white = Color(red: 0.97, green: 0.97, blue: 0.96)
    static let red = Color(red: 0.88, green: 0.02, blue: 0.00)
    static let secondary = Color.white.opacity(0.58)
}

enum S5Type {
    private static let displayName = "Futura-CondensedExtraBold"

    static func display(_ size: CGFloat) -> Font {
        if UIFont(name: displayName, size: size) != nil {
            return .custom(displayName, fixedSize: size)
        }
        return .system(size: size, weight: .black, design: .default)
    }

    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func data(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct S5Wordmark: View {
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(S5Theme.red)
                Text("S5")
                    .font(S5Type.display(18))
                    .foregroundStyle(.white)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 0) {
                Text("STEINBERG")
                    .font(S5Type.display(14))
                    .tracking(0.7)
                Text("FIVE")
                    .font(S5Type.data(9))
                    .foregroundStyle(S5Theme.red)
                    .tracking(3.8)
            }
        }
        .foregroundStyle(.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Steinberg Five")
    }
}

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(S5Type.data(10))
            .tracking(1.7)
            .foregroundStyle(S5Theme.red)
    }
}

struct S5ProgressRing: View {
    let progress: Double
    var size: CGFloat = 58

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: size * 0.11)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(S5Theme.red, style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(S5Type.data(size * 0.17, weight: .black))
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(Int(progress * 100)) percent complete")
    }
}
