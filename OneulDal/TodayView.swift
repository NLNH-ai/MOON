import Foundation
import SwiftUI

private enum TodaySheet: Identifiable {
    case location
    case settings

    var id: String {
        switch self {
        case .location:
            return "location"
        case .settings:
            return "settings"
        }
    }
}

struct TodayView: View {
    @Binding var selectedTab: AppTab
    @State private var selectedCity = "서울"
    @State private var activeSheet: TodaySheet?

    private let today = MoonFixtures.today

    var body: some View {
        NavigationStack {
            ZStack {
                MoonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        topBar
                        moonHero
                        statusRow
                        MoonTimesPanel(day: today)
                        nextFullMoonCard
                        monthPreview
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .padding(.bottom, 104)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .location:
                    LocationPickerSheet(selectedCity: $selectedCity)
                        .presentationDetents([.medium])
                case .settings:
                    SettingsSheet()
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }

    private var topBar: some View {
        ZStack {
            Text("오늘달")
                .font(.system(size: MoonLayout.headerTitleTextSize, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            HStack {
                Button {
                    activeSheet = .location
                } label: {
                    MoonChip(selectedCity, symbolName: "location.fill", tint: Color.moonAqua)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("지역 \(selectedCity)")

                Spacer()

                Button {
                    activeSheet = .settings
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.moonText)
                        .frame(width: 42, height: 42)
                        .background(.white.opacity(0.07), in: Circle())
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .accessibilityLabel("설정")
            }
        }
        .frame(height: 46)
    }

    private var moonHero: some View {
        GlassPanel(padding: 16) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("오늘의 달")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.moonGold)

                        Text("2026. 7. 2 · 오늘")
                            .font(.system(size: MoonLayout.heroDateTextSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.moonSubtext)
                    }

                    Spacer()

                    MoonChip("밝기 \(today.illumination)%", symbolName: "sun.max", tint: Color.moonGold)
                }

                HStack(alignment: .center, spacing: 18) {
                    Image("MoonWaxingGibbous")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 132, height: 132)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.moonGold.opacity(0.20), lineWidth: 1)
                        )
                        .shadow(color: Color.moonGold.opacity(0.16), radius: 14, x: 0, y: 7)
                        .accessibilityLabel("상현망간의 달 이미지")

                    VStack(alignment: .leading, spacing: 8) {
                        Text(today.phaseNameKo)
                            .font(.system(size: MoonLayout.heroPhaseTitleTextSize, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.moonText)
                            .minimumScaleFactor(0.70)
                            .lineLimit(2)

                        Text(today.phaseNameEn)
                            .font(.system(size: MoonLayout.heroPhaseSubtitleTextSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.moonSubtext)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Label(today.waxingText, systemImage: "arrow.up.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.moonAqua)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var statusRow: some View {
        GlassPanel(padding: 14) {
            HStack(spacing: 0) {
                StatusMetric(symbol: "sun.max", label: "밝기", value: "\(today.illumination)%")
                StatusDivider()
                StatusMetric(symbol: "moon", label: "달령", value: String(format: "%.1f일", today.moonAge))
                StatusDivider()
                StatusMetric(symbol: "circle.fill", label: "지금", value: "떠 있어요", tint: Color.moonGold)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var nextFullMoonCard: some View {
        Button {
            selectedTab = .calendar
        } label: {
            GlassPanel {
                HStack(spacing: 18) {
                    MoonPhaseGlyph(
                        illumination: 100,
                        isWaxing: false,
                        size: 64,
                        isEmphasized: true
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("다음 보름달")
                            .font(.system(size: MoonLayout.nextMoonTitleTextSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.moonText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text("7월 7일 화요일")
                            .font(.system(size: MoonLayout.nextMoonDateTextSize, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.moonSubtext)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

                    Spacer(minLength: 8)

                    HStack(spacing: 10) {
                        Text("D-5")
                            .font(.system(size: MoonLayout.nextMoonCountdownTextSize, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.moonGold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                            .layoutPriority(1)

                        Image(systemName: "chevron.right")
                            .font(.system(size: MoonLayout.nextMoonChevronSize, weight: .semibold))
                            .foregroundStyle(Color.moonSubtext.opacity(MoonLayout.nextMoonChevronOpacity))
                            .frame(width: MoonLayout.nextMoonChevronSize, height: MoonLayout.nextMoonChevronSize + 4)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(RoundedRectangle(cornerRadius: MoonLayout.cardCornerRadius, style: .continuous))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("다음 보름달 7월 7일, 달력으로 이동")
    }

    private var monthPreview: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text("이번 달 미리보기")
                    .font(.system(size: MoonLayout.monthPreviewTitleTextSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.moonText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .layoutPriority(1)

                Spacer(minLength: 10)

                Button {
                    selectedTab = .calendar
                } label: {
                    Text("달력 전체 보기")
                        .font(.system(size: MoonLayout.monthPreviewActionTextSize, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .foregroundStyle(Color.moonGold.opacity(MoonLayout.monthPreviewActionOpacity))
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("달력 전체 보기")
            }

            HStack(spacing: 7) {
                ForEach(1...7, id: \.self) { day in
                    let moonDay = MoonFixtures.day(for: day)

                    WeekMoonCell(
                        day: moonDay,
                        isToday: day == today.day
                    )
                }
            }
        }
        .padding(.top, MoonLayout.monthPreviewTopPadding)
    }
}

private struct StatusMetric: View {
    let symbol: String
    let label: String
    let value: String
    var tint: Color = Color.moonText

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: MoonLayout.statusMetricContentSpacing) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)

                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.moonSubtext)
            }

            Text(value)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(value)")
    }
}

private struct StatusDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(MoonLayout.statusDividerOpacity))
            .frame(width: 1, height: MoonLayout.statusDividerHeight)
            .padding(.horizontal, MoonLayout.statusDividerHorizontalInset)
    }
}

private struct WeekMoonCell: View {
    let day: MoonDay
    let isToday: Bool

    private var moonSize: CGFloat {
        if isToday {
            return MoonLayout.selectedDayBadgeSize
        }
        return MoonLayout.previewMoonCellSize
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("\(day.day)")
                .font(.system(size: isToday ? 20 : 18, weight: isToday ? .bold : .medium, design: .rounded))
                .foregroundStyle(isToday ? Color.moonBackground : Color.moonSubtext)
                .frame(
                    width: isToday ? MoonLayout.selectedDayBadgeSize : 32,
                    height: isToday ? MoonLayout.selectedDayBadgeSize : 32
                )
                .background(isToday ? Color.moonGold : Color.clear, in: Circle())

            MoonPhaseGlyph(
                illumination: day.illumination,
                isWaxing: day.isWaxing,
                size: moonSize,
                isEmphasized: isToday || day.isMajorPhase
            )

            Text("\(day.illumination)%")
                .font(.system(
                    size: isToday ? 17 : 16,
                    weight: isToday ? .bold : .medium,
                    design: .rounded
                ))
                .foregroundStyle(
                    isToday ? Color.moonGold.opacity(0.96) : Color.moonSubtext.opacity(MoonLayout.previewMoonPercentOpacity)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(day.dateTitle), \(day.phaseNameKo), 밝기 \(day.illumination)%")
    }
}

private struct MoonTimesPanel: View {
    let day: MoonDay

    var body: some View {
        GlassPanel(padding: 16) {
            HStack(spacing: 0) {
                TimeMetricView(symbol: "arrow.up", title: "월출", time: day.moonrise)
                VerticalDivider()
                TimeMetricView(symbol: "moon.haze", title: "남중", time: day.transit)
                VerticalDivider()
                TimeMetricView(symbol: "arrow.down", title: "월몰", time: day.moonset)
            }
            .padding(.vertical, 2)
        }
    }
}

private struct TimeMetricView: View {
    let symbol: String
    let title: String
    let time: String

    var body: some View {
        VStack(spacing: MoonLayout.timeMetricStackSpacing) {
            VStack(spacing: MoonLayout.timeMetricLabelSpacing) {
                Image(systemName: symbol)
                    .font(.system(size: MoonLayout.timeIconSize, weight: .medium))
                    .foregroundStyle(Color.moonSubtext)

                Text(title)
                    .font(.system(size: MoonLayout.timeLabelTextSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.moonSubtext)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Text(time)
                .font(.system(size: MoonLayout.timeValueFontSize, weight: .semibold, design: .serif))
                .monospacedDigit()
                .foregroundStyle(Color.moonText)
                .minimumScaleFactor(0.62)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct VerticalDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(MoonLayout.timeDividerOpacity))
            .frame(width: 1, height: MoonLayout.timeDividerHeight)
            .padding(.horizontal, MoonLayout.timeDividerHorizontalInset)
    }
}

#Preview {
    TodayView(selectedTab: .constant(.today))
}
