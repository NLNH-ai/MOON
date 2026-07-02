import SwiftUI

struct MoonCalendarView: View {
    @State private var selectedDay = MoonFixtures.day(for: 7)

    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    private let leadingBlanks = 2

    var body: some View {
        NavigationStack {
            ZStack {
                MoonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        calendarHeader
                        weekdayHeader
                        calendarGrid
                        SelectedMoonDayPanel(day: selectedDay)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 34)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var calendarHeader: some View {
        HStack {
            Button {
                selectedDay = MoonFixtures.day(for: max(1, selectedDay.day - 1))
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("이전 날짜")

            Spacer()

            VStack(spacing: 4) {
                Text("2026년 7월")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.moonText)

                Text("서울 기준")
                    .font(.subheadline)
                    .foregroundStyle(Color.moonSubtext)
            }

            Spacer()

            Button {
                selectedDay = MoonFixtures.day(for: min(31, selectedDay.day + 1))
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("다음 날짜")
        }
        .foregroundStyle(Color.moonGold)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.moonSubtext)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let cells: [Int?] = Array(repeating: nil, count: leadingBlanks) + Array(1...31).map(Optional.some)

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, dayNumber in
                if let dayNumber {
                    let day = MoonFixtures.day(for: dayNumber)

                    CalendarMoonCell(
                        day: day,
                        isSelected: selectedDay.day == dayNumber,
                        isToday: dayNumber == MoonFixtures.today.day
                    ) {
                        selectedDay = day
                    }
                } else {
                    Color.clear
                        .frame(height: 68)
                }
            }
        }
    }
}

private struct CalendarMoonCell: View {
    let day: MoonDay
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(day.day)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isToday ? Color.black : Color.moonText)
                    .frame(width: 22, height: 22)
                    .background(isToday ? Color.moonGold : Color.clear, in: Circle())

                Image("MoonWaxingGibbous")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .opacity(max(0.28, Double(day.illumination) / 100.0))

                Text(day.majorPhaseLabel ?? "\(day.illumination)%")
                    .font(.system(size: 10, weight: day.isMajorPhase ? .bold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(day.isMajorPhase ? Color.moonGold : Color.moonSubtext)
            }
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.moonSurface2 : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? Color.moonGold.opacity(0.55) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(day.dateTitle), \(day.phaseNameKo), \(day.brightnessText)")
    }
}

private struct SelectedMoonDayPanel: View {
    let day: MoonDay

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    Image("MoonWaxingGibbous")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 74, height: 74)
                        .clipShape(Circle())
                        .opacity(max(0.35, Double(day.illumination) / 100.0))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(day.dateTitle)
                            .font(.headline)
                            .foregroundStyle(Color.moonText)

                        Text(day.phaseNameKo)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(day.isMajorPhase ? Color.moonGold : Color.moonText)

                        Text("\(day.brightnessText) · \(day.moonAgeText)")
                            .font(.subheadline)
                            .foregroundStyle(Color.moonSubtext)
                    }

                    Spacer()
                }

                Divider().background(.white.opacity(0.12))

                HStack {
                    DetailMetric(title: "월출", value: day.moonrise)
                    DetailMetric(title: "남중", value: day.transit)
                    DetailMetric(title: "월몰", value: day.moonset)
                }

                HStack(spacing: 10) {
                    Button("알림 추가") {}
                        .buttonStyle(PillButtonStyle())

                    Button("사진 모드") {}
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.08), in: Capsule())
                        .foregroundStyle(Color.moonText)
                }
            }
        }
    }
}

private struct DetailMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.moonSubtext)

            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.moonText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MoonCalendarView()
}
