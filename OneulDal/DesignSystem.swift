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
    static let cardCornerRadius: CGFloat = 24
    static let compactPanelCornerRadius: CGFloat = 18
    static let glassPanelFillOpacity: Double = 0.88
    static let glassPanelShadowOpacity: Double = 0.13
    static let glassPanelBorderOpacity: Double = 0.10
    static let headerSideRailWidth: CGFloat = 84
    static let headerTitleTextSize: CGFloat = 32
    static let headerLocationTextSize: CGFloat = 21
    static let headerSettingsIconSize: CGFloat = 29
    static let todayMoonDiameter: CGFloat = 252
    static let todayMinimumMoonDiameter: CGFloat = 240
    static let todayComfortableViewportHeight: CGFloat = 790
    static let todayMinimumViewportHeight: CGFloat = 650
    static let moonSurfaceScale: CGFloat = 1.27
    static let moonSurfaceOffsetYRatio: CGFloat = 0.028
    static let todayDateTextSize: CGFloat = 13
    static let todayPhaseTitleTextSize: CGFloat = 17
    static let todayBrightnessTextSize: CGFloat = 14
    static let todayStatusTextSize: CGFloat = 26
    static let todayNextEventTextSize: CGFloat = 15
    static let nextMoonLinkTextSize: CGFloat = 17
    static let previewMoonThumbnailSize: CGFloat = 82
    static let previewMoonThumbnailStrokeOpacity: Double = 0.16
    static let previewMoonThumbnailGlowOpacity: Double = 0.08
    static let monthPreviewActionOpacity: Double = 0.62
    static let monthPreviewActionTextSize: CGFloat = 16
    static let monthPreviewTitleTextSize: CGFloat = 23
    static let monthPreviewTopPadding: CGFloat = 16
    static let previewMoonPercentOpacity: Double = 0.64
    static let previewMoonCellSize: CGFloat = 36
    static let selectedDayBadgeSize: CGFloat = 35
    static let previewDayTextSize: CGFloat = 17
    static let selectedPreviewDayTextSize: CGFloat = 19
    static let previewPercentTextSize: CGFloat = 15
    static let selectedPreviewPercentTextSize: CGFloat = 16
    static let tabSelectedOpacity: Double = 0.88
    static let tabNormalOpacity: Double = 0.54
    static let tabBackgroundOpacity: Double = 0.96
    static let tabBarContentSpacing: CGFloat = 22
}

struct TodayLayoutMetrics {
    let compressionProgress: CGFloat
    let sectionSpacing: CGFloat
    let topPadding: CGFloat
    let moonDiameter: CGFloat
    let heroSpacing: CGFloat
    let phaseTopPadding: CGFloat
    let nextMoonVerticalPadding: CGFloat
    let monthPreviewTopPadding: CGFloat
    let monthPreviewSpacing: CGFloat
    let previewMoonCellSize: CGFloat
    let selectedDayBadgeSize: CGFloat

    init(availableHeight: CGFloat) {
        let compressionRange = MoonLayout.todayComfortableViewportHeight - MoonLayout.todayMinimumViewportHeight
        let overflow = max(0, MoonLayout.todayComfortableViewportHeight - availableHeight)
        let progress = min(max(overflow / compressionRange, 0), 1)

        compressionProgress = progress
        sectionSpacing = Self.interpolate(from: 14, to: 10, progress: progress)
        topPadding = Self.interpolate(from: 10, to: 8, progress: progress)
        moonDiameter = Self.interpolate(
            from: MoonLayout.todayMoonDiameter,
            to: MoonLayout.todayMinimumMoonDiameter,
            progress: progress
        )
        heroSpacing = Self.interpolate(from: 16, to: 12, progress: progress)
        phaseTopPadding = Self.interpolate(from: 12, to: 8, progress: progress)
        nextMoonVerticalPadding = Self.interpolate(from: 13, to: 10, progress: progress)
        monthPreviewTopPadding = Self.interpolate(from: 10, to: 4, progress: progress)
        monthPreviewSpacing = Self.interpolate(from: 14, to: 10, progress: progress)
        previewMoonCellSize = Self.interpolate(
            from: MoonLayout.previewMoonCellSize,
            to: 34,
            progress: progress
        )
        selectedDayBadgeSize = Self.interpolate(
            from: MoonLayout.selectedDayBadgeSize,
            to: 33,
            progress: progress
        )
    }

    private static func interpolate(from roomy: CGFloat, to compact: CGFloat, progress: CGFloat) -> CGFloat {
        roomy + ((compact - roomy) * progress)
    }
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
                    Color.moonGold.opacity(0.16),
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
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
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
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
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

struct MoonPhaseGlyph: View {
    let illumination: Int
    let isWaxing: Bool
    var size: CGFloat
    var accent: Color = Color.moonGold
    var isEmphasized = false

    private var lightFraction: CGFloat {
        CGFloat(min(max(illumination, 0), 100)) / 100
    }

    private var shadowOffset: CGFloat {
        size * lightFraction
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(isEmphasized ? 0.98 : 0.84))

            Circle()
                .fill(Color.moonBackground.opacity(0.96))
                .offset(x: isWaxing ? -shadowOffset : shadowOffset)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    isEmphasized ? accent.opacity(0.48) : Color.white.opacity(0.12),
                    lineWidth: 1
                )
        )
        .shadow(
            color: accent.opacity(isEmphasized ? 0.22 : 0.08),
            radius: isEmphasized ? 8 : 3,
            x: 0,
            y: 0
        )
        .accessibilityHidden(true)
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
