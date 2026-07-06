import SwiftUI

extension Color {
    static let moonBackground = Color(red: 0.027, green: 0.043, blue: 0.086)
    static let moonSurface = Color(red: 0.063, green: 0.094, blue: 0.145)
    static let moonSurface2 = Color(red: 0.086, green: 0.122, blue: 0.196)
    static let moonGold = Color(red: 0.905, green: 0.843, blue: 0.604)
    static let moonAqua = Color(red: 0.392, green: 0.788, blue: 0.824)
    static let moonText = Color(red: 0.961, green: 0.969, blue: 0.984)
    static let moonSubtext = Color(red: 0.667, green: 0.706, blue: 0.773)
}

enum MoonLayout {
    static let cardCornerRadius: CGFloat = 30
    static let glassPanelFillOpacity: Double = 0.86
    static let glassPanelShadowOpacity: Double = 0.20
    static let glassPanelBorderOpacity: Double = 0.10
    static let headerSideRailWidth: CGFloat = 84
    static let headerTitleTextSize: CGFloat = 54
    static let headerLocationTextSize: CGFloat = 23
    static let headerSettingsIconSize: CGFloat = 32
    static let heroImageHorizontalInset: CGFloat = 30
    static let heroImageCornerRadius: CGFloat = 6
    static let heroImageBorderOpacity: Double = 0.03
    static let heroImageShadowOpacity: Double = 0.11
    static let heroImageShadowRadius: CGFloat = 18
    static let heroImageShadowYOffset: CGFloat = 6
    static let heroDateTextSize: CGFloat = 28
    static let heroPhaseTitleTextSize: CGFloat = 50
    static let heroPhaseSubtitleTextSize: CGFloat = 22
    static let nextMoonTitleTextSize: CGFloat = 28
    static let nextMoonDateTextSize: CGFloat = 20
    static let nextMoonCountdownTextSize: CGFloat = 30
    static let nextMoonChevronOpacity: Double = 0.72
    static let nextMoonChevronSize: CGFloat = 26
    static let previewMoonThumbnailSize: CGFloat = 82
    static let previewMoonThumbnailStrokeOpacity: Double = 0.20
    static let previewMoonThumbnailGlowOpacity: Double = 0.08
    static let monthPreviewActionOpacity: Double = 0.82
    static let monthPreviewActionTextSize: CGFloat = 19
    static let monthPreviewTitleTextSize: CGFloat = 26
    static let monthPreviewTopPadding: CGFloat = 18
    static let previewMoonPercentOpacity: Double = 0.82
    static let previewMoonCellSize: CGFloat = 36
    static let selectedDayBadgeSize: CGFloat = 36
    static let tabSelectedOpacity: Double = 0.92
    static let tabNormalOpacity: Double = 0.66
    static let tabBackgroundOpacity: Double = 0.68
    static let statusMetricTextSize: CGFloat = 19
    static let statusMetricIconSize: CGFloat = 25
    static let statusMetricIconFrameSize: CGFloat = 30
    static let statusMetricContentSpacing: CGFloat = 8
    static let statusDividerHeight: CGFloat = 52
    static let statusDividerHorizontalInset: CGFloat = 2
    static let statusDividerOpacity: Double = 0.08
    static let timeDividerHeight: CGFloat = 112
    static let timeDividerHorizontalInset: CGFloat = 4
    static let timeDividerOpacity: Double = 0.08
    static let timeIconSize: CGFloat = 30
    static let timeLabelTextSize: CGFloat = 23
    static let timeMetricStackSpacing: CGFloat = 12
    static let timeMetricLabelSpacing: CGFloat = 8
    static let timeValueFontSize: CGFloat = 42
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
                RoundedRectangle(cornerRadius: MoonLayout.cardCornerRadius, style: .continuous)
                    .fill(Color.moonSurface.opacity(MoonLayout.glassPanelFillOpacity))
                    .shadow(color: .black.opacity(MoonLayout.glassPanelShadowOpacity), radius: 18, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: MoonLayout.cardCornerRadius, style: .continuous)
                            .stroke(.white.opacity(MoonLayout.glassPanelBorderOpacity), lineWidth: 1)
                    )
            )
    }
}

struct ScreenHeader<Accessory: View>: View {
    let title: String
    let eyebrow: String?
    let subtitle: String
    let accessory: Accessory

    init(
        title: String,
        eyebrow: String? = nil,
        subtitle: String,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.eyebrow = eyebrow
        self.subtitle = subtitle
        self.accessory = accessory()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                if let eyebrow {
                    Text(eyebrow)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.moonGold)
                        .textCase(.uppercase)
                }

                Text(title)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.moonText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(subtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.moonSubtext)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            accessory
        }
    }
}

extension ScreenHeader where Accessory == EmptyView {
    init(title: String, eyebrow: String? = nil, subtitle: String) {
        self.title = title
        self.eyebrow = eyebrow
        self.subtitle = subtitle
        self.accessory = EmptyView()
    }
}

struct MoonChip: View {
    let title: String
    let symbolName: String?
    var tint: Color = Color.moonGold
    var accessibilityLabel: String?

    init(
        _ title: String,
        symbolName: String? = nil,
        tint: Color = Color.moonGold,
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.symbolName = symbolName
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        HStack(spacing: 6) {
            if let symbolName {
                Image(systemName: symbolName)
                    .font(.caption.weight(.bold))
            }

            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .foregroundStyle(Color.moonBackground)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(tint, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? title)
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

struct SecondaryPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white.opacity(configuration.isPressed ? 0.13 : 0.08), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(Color.moonText)
    }
}
