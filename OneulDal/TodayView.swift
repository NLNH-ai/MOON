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
                    VStack(spacing: 22) {
                        topBar

                        Text("2026. 7. 2 오늘")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Color.moonSubtext)
                            .padding(.top, 10)

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
        HStack {
            Button {
                activeSheet = .location
            } label: {
                Label(selectedCity, systemImage: "location.circle")
                    .font(.headline)
                    .foregroundStyle(Color.moonText)
            }

            Spacer()

            Text("오늘달")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.moonText)

            Spacer()

            Button {
                activeSheet = .settings
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.moonText)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("설정")
        }
    }

    private var moonHero: some View {
        VStack(spacing: 18) {
            Image("MoonWaxingGibbous")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300)
                .shadow(color: Color.moonGold.opacity(0.28), radius: 26, x: 0, y: 0)
                .accessibilityLabel("상현망간의 달 이미지")

            VStack(spacing: 8) {
                Text(today.phaseNameKo)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.moonGold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text(today.phaseNameEn)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Color.moonSubtext)
            }
        }
    }

    private var statusRow: some View {
        HStack(spacing: 12) {
            StatusMetric(symbol: "sun.max", text: today.brightnessText)
            Divider().background(.white.opacity(0.24))
            StatusMetric(symbol: "moon", text: today.moonAgeText)
            Divider().background(.white.opacity(0.24))
            StatusMetric(symbol: "circle.fill", text: today.visibilityMessage, tint: Color.moonGold)
        }
        .frame(height: 42)
        .foregroundStyle(Color.moonText)
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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("다음 보름달")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Color.moonText)

                        Text("7월 7일 화요일")
                            .font(.subheadline)
                            .foregroundStyle(Color.moonSubtext)
                    }

                    Spacer()

                    Text("D-5")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.moonGold)

                    Image(systemName: "chevron.right")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.moonSubtext)
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
    let text: String
    var tint: Color = Color.moonText

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
            Text(text)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
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
                .font(.system(size: 32, weight: .medium, design: .serif))
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
