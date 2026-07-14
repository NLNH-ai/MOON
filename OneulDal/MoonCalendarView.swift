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
                    VStack(spacing: 16) {
                        header
                        monthNavigator
                        calendarBoard
                        SelectedMoonDayPanel(day: selectedDay)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .padding(.bottom, 34)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        ScreenHeader(
            title: "달력",
            eyebrow: "2026년 7월",
            subtitle: "서울 기준 월출과 달의 밝기를 한눈에 봅니다."
        ) {
            MoonChip("서울", symbolName: "location.fill", tint: Color.moonAqua)
        }
    }

    private var monthNavigator: some View {
        GlassPanel(padding: 12) {
            HStack(spacing: 14) {
                navigationButton(symbol: "chevron.left", accessibilityLabel: "이전 날짜") {
                    selectedDay = MoonFixtures.day(for: max(1, selectedDay.day - 1))
                }

                VStack(spacing: 5) {
                    Text(selectedDay.dateTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.moonText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text("\(selectedDay.phaseNameKo) · \(selectedDay.brightnessText)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.moonSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .frame(maxWidth: .infinity)

                navigationButton(symbol: "chevron.right", accessibilityLabel: "다음 날짜") {
                    selectedDay = MoonFixtures.day(for: min(31, selectedDay.day + 1))
                }
            }
        }
    }

    private func navigationButton(
        symbol: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.moonGold)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.07), in: Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var calendarBoard: some View {
        GlassPanel(padding: 14) {
            VStack(spacing: 12) {
                weekdayHeader
                calendarGrid
            }
        }
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

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
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
                        .frame(height: 64)
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
                    .foregroundStyle(dayTextColor)
                    .frame(width: 22, height: 22)
                    .background(isToday ? Color.moonGold : Color.clear, in: Circle())

                MoonPhaseGlyph(
                    illumination: day.illumination,
                    isWaxing: day.isWaxing,
                    size: isSelected || day.isMajorPhase ? 28 : 24,
                    isEmphasized: isSelected || day.isMajorPhase
                )

                Text(day.majorPhaseLabel ?? "\(day.illumination)%")
                    .font(.system(size: 10, weight: day.isMajorPhase ? .bold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(day.isMajorPhase ? Color.moonGold : Color.moonSubtext)
            }
            .frame(maxWidth: .infinity, minHeight: 62)
            .background(
                RoundedRectangle(cornerRadius: MoonLayout.compactPanelCornerRadius, style: .continuous)
                    .fill(cellFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: MoonLayout.compactPanelCornerRadius, style: .continuous)
                            .stroke(cellStroke, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(day.dateTitle), \(day.phaseNameKo), \(day.brightnessText)")
        .accessibilityHint("탭하면 이 날짜의 월출과 월몰 시간을 봅니다.")
    }

    private var dayTextColor: Color {
        if isToday {
            return Color.moonBackground
        }

        return isSelected ? Color.moonGold : Color.moonText
    }

    private var cellFill: Color {
        if isSelected {
            return Color.moonGold.opacity(0.11)
        }

        return isToday ? Color.moonGold.opacity(0.08) : Color.white.opacity(0.035)
    }

    private var cellStroke: Color {
        if isSelected {
            return Color.moonGold.opacity(0.55)
        }

        return isToday ? Color.moonGold.opacity(0.28) : Color.white.opacity(0.05)
    }
}

private struct SelectedMoonDayPanel: View {
    let day: MoonDay

    var body: some View {
        GlassPanel(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 16) {
                    MoonPhaseGlyph(
                        illumination: day.illumination,
                        isWaxing: day.isWaxing,
                        size: 68,
                        isEmphasized: day.isMajorPhase
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(day.dateTitle)
                            .font(.headline)
                            .foregroundStyle(Color.moonText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Text(day.phaseNameKo)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(day.isMajorPhase ? Color.moonGold : Color.moonText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(day.phaseNameEn)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.moonSubtext)
                            .lineLimit(1)

                        Text("\(day.brightnessText) · \(day.moonAgeText)")
                            .font(.subheadline)
                            .foregroundStyle(Color.moonSubtext)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }

                    Spacer()

                    MoonChip(
                        day.majorPhaseLabel ?? day.waxingText,
                        symbolName: day.isWaxing ? "arrow.up.right" : "arrow.down.right",
                        tint: day.isMajorPhase ? Color.moonGold : Color.moonAqua
                    )
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
                        .buttonStyle(SecondaryPillButtonStyle())
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
