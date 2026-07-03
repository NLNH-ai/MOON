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
                    VStack(spacing: 20) {
                        topBar
                        moonHero
                        statusRow
                        MoonTimesPanel(day: today)
                        nextFullMoonCard
                        monthPreview
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
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
        HStack(alignment: .center, spacing: 8) {
            Button {
                activeSheet = .location
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 26, weight: .semibold))
                    Text(selectedCity)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                }
                .foregroundStyle(Color.moonText)
                .frame(width: MoonLayout.headerSideRailWidth, height: 52, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("지역 \(selectedCity)")

            Text("오늘달")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .frame(maxWidth: .infinity)

            Button {
                activeSheet = .settings
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color.moonText)
                    .frame(width: 52, height: 52)
                    .frame(width: MoonLayout.headerSideRailWidth, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("설정")
        }
    }

    private var moonHero: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("2026. 7. 2 오늘")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(Color.moonSubtext)
                    .frame(maxWidth: .infinity)

                Image("MoonWaxingGibbous")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(.white.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: Color.moonGold.opacity(0.14), radius: 24, x: 0, y: 10)
                    .padding(.horizontal, MoonLayout.heroImageHorizontalInset)
                    .accessibilityLabel("상현망간의 달 이미지")
            }

            VStack(spacing: 8) {
                Text(today.phaseNameKo)
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.moonGold)
                    .minimumScaleFactor(0.68)
                    .lineLimit(1)

                Text(today.phaseNameEn)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.moonSubtext)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
        }
    }

    private var statusRow: some View {
        HStack(spacing: 0) {
            StatusMetric(symbol: "sun.max", label: "밝기", value: "\(today.illumination)%")
            StatusDivider()
            StatusMetric(symbol: "moon", label: "달령", value: String(format: "%.1f일", today.moonAge))
            StatusDivider()
            StatusMetric(symbol: "circle.fill", label: "지금", value: "떠 있어요", tint: Color.moonGold)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    private var nextFullMoonCard: some View {
        Button {
            selectedTab = .calendar
        } label: {
            GlassPanel {
                HStack(spacing: 18) {
                    Image("MoonWaxingGibbous")
                        .resizable()
                        .scaledToFill()
                        .frame(width: MoonLayout.previewMoonThumbnailSize, height: MoonLayout.previewMoonThumbnailSize)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.moonGold.opacity(0.34), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("다음 보름달")
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.moonText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text("7월 7일 화요일")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.moonSubtext)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }

                    Spacer(minLength: 12)

                    HStack(spacing: 10) {
                        Text("D-5")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.moonGold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                            .layoutPriority(1)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(Color.moonSubtext)
                            .frame(width: 32, height: 32)
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
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.moonText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 12)

                Button {
                    selectedTab = .calendar
                } label: {
                    Text("달력 전체 보기")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.moonGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
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
                        isToday: day == today.day,
                        isMilestone: moonDay.isMajorPhase
                    )
                }
            }
        }
        .padding(.top, 2)
    }
}

private struct StatusMetric: View {
    let symbol: String
    let label: String
    let value: String
    var tint: Color = Color.moonText

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)

            Text("\(label) \(value)")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(value)")
    }
}

private struct StatusDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.16))
            .frame(width: 1, height: 62)
            .padding(.horizontal, 4)
    }
}

private struct WeekMoonCell: View {
    let day: MoonDay
    let isToday: Bool
    let isMilestone: Bool

    private var moonSize: CGFloat {
        isMilestone ? 40 : 34
    }

    private var phaseShadowOpacity: Double {
        max(0.0, min(0.52, Double(100 - day.illumination) / 82.0))
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("\(day.day)")
                .font(.system(size: isToday ? 20 : 18, weight: .bold, design: .rounded))
                .foregroundStyle(isToday ? Color.moonBackground : Color.moonSubtext)
                .frame(
                    width: isToday ? MoonLayout.selectedDayBadgeSize : 32,
                    height: isToday ? MoonLayout.selectedDayBadgeSize : 32
                )
                .background(isToday ? Color.moonGold : Color.clear, in: Circle())

            Image("MoonWaxingGibbous")
                .resizable()
                .scaledToFill()
                .frame(width: moonSize, height: moonSize)
                .clipShape(Circle())
                .opacity(max(0.42, Double(day.illumination) / 100.0))
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(phaseShadowOpacity),
                            Color.black.opacity(phaseShadowOpacity * 0.68),
                            Color.clear
                        ],
                        startPoint: day.isWaxing ? .leading : .trailing,
                        endPoint: day.isWaxing ? .trailing : .leading
                    )
                    .clipShape(Circle())
                    .blendMode(.multiply)
                }
                .overlay(
                    Circle()
                        .stroke(isMilestone ? Color.moonGold.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.moonGold.opacity(isMilestone ? 0.18 : 0.06), radius: isMilestone ? 8 : 4, x: 0, y: 0)
                .accessibilityHidden(true)

            Text(isMilestone ? (day.majorPhaseLabel ?? "\(day.illumination)%") : "\(day.illumination)%")
                .font(.system(size: 17, weight: isMilestone ? .bold : .medium, design: .rounded))
                .foregroundStyle(isMilestone ? Color.moonGold : Color.moonSubtext)
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
        GlassPanel {
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
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(Color.moonSubtext)

            Text(title)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.moonSubtext)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(time)
                .font(.system(size: 48, weight: .semibold, design: .rounded))
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
            .fill(.white.opacity(0.12))
            .frame(width: 1, height: 132)
            .padding(.horizontal, MoonLayout.timeDividerHorizontalInset)
    }
}

#Preview {
    TodayView(selectedTab: .constant(.today))
}
