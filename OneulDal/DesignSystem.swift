import SwiftUI

extension Color {
    static let moonBackground = Color(red: 0.027, green: 0.043, blue: 0.086)
    static let moonSurface = Color(red: 0.063, green: 0.094, blue: 0.145)
    static let moonSurface2 = Color(red: 0.086, green: 0.122, blue: 0.196)
    static let moonGold = Color(red: 0.905, green: 0.843, blue: 0.604)
    static let moonText = Color(red: 0.961, green: 0.969, blue: 0.984)
    static let moonSubtext = Color(red: 0.667, green: 0.706, blue: 0.773)
}

struct MoonBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .black,
                    Color.moonBackground,
                    Color(red: 0.014, green: 0.027, blue: 0.059)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    Color.moonGold.opacity(0.22),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 320
            )

            ForEach(0..<16, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(index.isMultiple(of: 3) ? 0.26 : 0.14))
                    .frame(width: index.isMultiple(of: 4) ? 2 : 1, height: index.isMultiple(of: 4) ? 2 : 1)
                    .offset(x: CGFloat((index * 47) % 320) - 160, y: CGFloat((index * 71) % 660) - 310)
            }
        }
        .ignoresSafeArea()
    }
}

struct GlassPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.moonSurface.opacity(0.82))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
            )
    }
}

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.moonGold.opacity(configuration.isPressed ? 0.72 : 1), in: Capsule())
            .foregroundStyle(.black)
    }
}
