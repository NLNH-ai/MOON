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
                HStack(spacing: 8) {
                    Text("2026. 7. 2")
                    Text("오늘")
                        .foregroundStyle(Color.moonGold)
                    Spacer()
                    Text(today.waxingText)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.moonSubtext)
                .textCase(.uppercase)

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
        HStack(spacing: 8) {
            StatusMetric(symbol: "sun.max", label: "밝기", value: "\(today.illumination)%")
            StatusMetric(symbol: "moon", label: "달령", value: String(format: "%.1f일", today.moonAge))
            StatusMetric(symbol: "circle.fill", label: "상태", value: "떠 있음", tint: Color.moonGold)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.black.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
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
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("다음 보름달 7월 7일, 달력으로 이동")
    }

    private var monthPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("이번 달 미리보기")
                    .font(.headline)
                    .foregroundStyle(Color.moonText)

                Spacer()

                Button("달력 전체 보기") {
                    selectedTab = .calendar
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.moonGold)
            }

            HStack(spacing: 12) {
                ForEach(1...7, id: \.self) { day in
                    let moonDay = MoonFixtures.day(for: day)

                    VStack(spacing: 6) {
                        Text("\(day)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(day == today.day ? Color.black : Color.moonSubtext)
                            .frame(width: 24, height: 24)
                            .background(day == today.day ? Color.moonGold : Color.clear, in: Circle())

                        Image("MoonWaxingGibbous")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 26, height: 26)
                            .clipShape(Circle())
                            .opacity(Double(moonDay.illumination) / 100.0)

                        Text("\(moonDay.illumination)%")
                            .font(.caption2)
                            .foregroundStyle(Color.moonSubtext)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 4)
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
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.moonSubtext)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.moonText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
        .background(Color.moonSurface.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
