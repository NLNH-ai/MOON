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
                    .padding(.bottom, 34)
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
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, 92)

            HStack {
                Button {
                    activeSheet = .location
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "location.fill")
                            .font(.caption.weight(.bold))
                        Text(selectedCity)
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(Color.moonText)
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .frame(maxWidth: 92)
                    .background(Color.moonSurface.opacity(0.62), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.09), lineWidth: 1)
                    )
                }

                Spacer()

                Button {
                    activeSheet = .settings
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.moonText)
                        .frame(width: 38, height: 38)
                        .background(Color.moonSurface.opacity(0.62), in: Circle())
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.09), lineWidth: 1)
                        )
                }
                .accessibilityLabel("설정")
            }
        }
    }

    private var moonHero: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("2026. 7. 2 오늘")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .foregroundStyle(Color.moonSubtext)
                    .frame(maxWidth: .infinity)

                Image("MoonWaxingGibbous")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 292)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.moonGold.opacity(0.2), radius: 30, x: 0, y: 12)
                    .accessibilityLabel("상현망간의 달 이미지")
            }

            VStack(spacing: 8) {
                Text(today.phaseNameKo)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.moonGold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text(today.phaseNameEn)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color.moonSubtext)
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
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private var nextFullMoonCard: some View {
        Button {
            selectedTab = .calendar
        } label: {
            GlassPanel {
                HStack(spacing: 16) {
                    Image("MoonWaxingGibbous")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 62, height: 62)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.moonGold.opacity(0.28), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("다음 보름달")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Color.moonText)

                        Text("7월 7일 화요일")
                            .font(.subheadline)
                            .foregroundStyle(Color.moonSubtext)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Text("D-5")
                            .font(.title.weight(.heavy))
                            .monospacedDigit()
                            .foregroundStyle(Color.moonGold)

                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.moonBackground)
                            .frame(width: 30, height: 30)
                            .background(Color.moonGold, in: Circle())
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("다음 보름달 7월 7일, 달력으로 이동")
    }

    private var monthPreview: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("이번 달 미리보기")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.moonText)

                        Text("보름까지 밝아지는 한 주")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.moonSubtext)
                    }

                    Spacer()

                    Button {
                        selectedTab = .calendar
                    } label: {
                        Label("전체", systemImage: "calendar")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.moonBackground)
                            .padding(.horizontal, 10)
                            .frame(height: 30)
                            .background(Color.moonGold, in: Capsule())
                    }
                    .accessibilityLabel("달력 전체 보기")
                }

                HStack(spacing: 8) {
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
        }
    }
}

private struct StatusMetric: View {
    let symbol: String
    let label: String
    let value: String
    var tint: Color = Color.moonText

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.title3.weight(.regular))
                .foregroundStyle(tint)

            Text("\(label) \(value)")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
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
            .frame(width: 1, height: 50)
            .padding(.horizontal, 10)
    }
}

private struct WeekMoonCell: View {
    let day: MoonDay
    let isToday: Bool
    let isMilestone: Bool

    var body: some View {
        VStack(spacing: 7) {
            Text("\(day.day)")
                .font(.caption.weight(.bold))
                .foregroundStyle(isToday ? Color.moonBackground : Color.moonSubtext)
                .frame(width: 24, height: 24)
                .background(isToday ? Color.moonGold : Color.clear, in: Circle())

            Image("MoonWaxingGibbous")
                .resizable()
                .scaledToFill()
                .frame(width: isMilestone ? 30 : 26, height: isMilestone ? 30 : 26)
                .clipShape(Circle())
                .opacity(max(0.42, Double(day.illumination) / 100.0))
                .overlay(
                    Circle()
                        .stroke(isMilestone ? Color.moonGold.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
                )

            Text(isMilestone ? (day.majorPhaseLabel ?? "\(day.illumination)%") : "\(day.illumination)%")
                .font(.caption2.weight(isMilestone ? .bold : .medium))
                .foregroundStyle(isMilestone ? Color.moonGold : Color.moonSubtext)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isToday ? Color.moonGold.opacity(0.08) : Color.white.opacity(0.035))
        )
    }
}

private struct MoonTimesPanel: View {
    let day: MoonDay

    var body: some View {
        GlassPanel {
            VStack(spacing: 16) {
                HStack {
                    Text("오늘의 달 시간")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.moonText)

                    Spacer()

                    Text("서울 기준")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.moonSubtext)
                }

                HStack(spacing: 0) {
                    TimeMetricView(symbol: "arrow.up", title: "월출", time: day.moonrise)
                    VerticalDivider()
                    TimeMetricView(symbol: "moon.haze", title: "남중", time: day.transit)
                    VerticalDivider()
                    TimeMetricView(symbol: "arrow.down", title: "월몰", time: day.moonset)
                }
            }
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
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.moonSubtext)

            Text(title)
                .font(.headline)
                .foregroundStyle(Color.moonSubtext)

            Text(time)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.moonText)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct VerticalDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.12))
            .frame(width: 1, height: 104)
            .padding(.horizontal, 12)
    }
}

#Preview {
    TodayView(selectedTab: .constant(.today))
}
