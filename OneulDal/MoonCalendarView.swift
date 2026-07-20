import SwiftUI

struct MoonCalendarView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedDate: Date?
    @State private var photoModeDay: MoonDay?
    @State private var confirmationMessage: String?

    private var selectedDay: MoonDay? {
        guard let selectedDate else { return nil }
        return appModel.calendarDays.first(where: {
            appModel.calendar.isDate($0.date, inSameDayAs: selectedDate)
        })
    }

    private var weekdays: [String] {
        appModel.mondayStart
            ? ["월", "화", "수", "목", "금", "토", "일"]
            : ["일", "월", "화", "수", "목", "금", "토"]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MoonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header
                        monthNavigator
                        calendarBoard
                        if let selectedDay {
                            SelectedMoonDayPanel(
                                day: selectedDay,
                                addReminder: { addReminder(for: selectedDay) },
                                openPhotoMode: { photoModeDay = selectedDay }
                            )
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .padding(.bottom, MoonLayout.tabBarContentClearance)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear(perform: selectInitialDay)
            .onChange(of: appModel.calendarDays) { _, days in
                guard !days.isEmpty else { return }
                if let selectedDate,
                   days.contains(where: { appModel.calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
                    return
                }
                self.selectedDate = preferredSelection(in: days).date
            }
            .fullScreenCover(item: $photoModeDay) { day in
                MoonPhotoModeView(day: day, locationName: appModel.selectedLocation.name)
            }
            .alert(
                "알림을 추가했어요",
                isPresented: Binding(
                    get: { confirmationMessage != nil },
                    set: { if !$0 { confirmationMessage = nil } }
                )
            ) {
                Button("확인", role: .cancel) { confirmationMessage = nil }
            } message: {
                Text(confirmationMessage ?? "")
            }
        }
    }

    private var header: some View {
        ScreenHeader(
            title: "달력",
            eyebrow: monthTitle,
            subtitle: "\(appModel.selectedLocation.name) 기준 달의 밝기와 월출을 봅니다."
        ) {
            MoonChip(appModel.selectedLocation.name, symbolName: "location.fill", tint: Color.moonAqua)
        }
    }

    private var monthNavigator: some View {
        GlassPanel(padding: 12) {
            HStack(spacing: 14) {
                navigationButton(symbol: "chevron.left", accessibilityLabel: "이전 달") {
                    appModel.moveCalendarMonth(by: -1)
                }

                VStack(spacing: 4) {
                    Text(monthTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.moonText)
                        .lineLimit(1)

                    Text("날짜를 누르면 월출과 월몰을 확인할 수 있어요")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.moonSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                navigationButton(symbol: "chevron.right", accessibilityLabel: "다음 달") {
                    appModel.moveCalendarMonth(by: 1)
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
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.07), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.08), lineWidth: 1))
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var calendarBoard: some View {
        GlassPanel(padding: 12) {
            VStack(spacing: 10) {
                weekdayHeader
                calendarGrid
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.moonSubtext)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let blanks = leadingBlankCount
        let filledCount = blanks + appModel.calendarDays.count
        let trailingCount = (7 - (filledCount % 7)) % 7
        let cells: [MoonDay?] = Array(repeating: nil, count: blanks)
            + appModel.calendarDays.map(Optional.some)
            + Array(repeating: nil, count: trailingCount)

        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7),
            spacing: 7
        ) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let day {
                    CalendarMoonCell(
                        day: day,
                        isSelected: selectedDate.map {
                            appModel.calendar.isDate(day.date, inSameDayAs: $0)
                        } ?? false,
                        isToday: appModel.calendar.isDateInToday(day.date)
                    ) {
                        selectedDate = day.date
                    }
                } else {
                    Color.clear.frame(height: 62)
                }
            }
        }
    }

    private var leadingBlankCount: Int {
        let weekday = appModel.calendar.component(.weekday, from: appModel.calendarMonthStart)
        return appModel.mondayStart ? (weekday + 5) % 7 : weekday - 1
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.calendar = appModel.calendar
        formatter.timeZone = appModel.selectedLocation.timeZone
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: appModel.calendarMonthStart)
    }

    private func selectInitialDay() {
        guard selectedDate == nil, !appModel.calendarDays.isEmpty else { return }
        selectedDate = preferredSelection(in: appModel.calendarDays).date
    }

    private func preferredSelection(in days: [MoonDay]) -> MoonDay {
        days.first(where: { appModel.calendar.isDateInToday($0.date) }) ?? days[0]
    }

    private func addReminder(for day: MoonDay) {
        Task {
            do {
                try await appModel.addMoonriseReminder(for: day)
                confirmationMessage = "\(day.dateTitle) 월출 전에 알려드릴게요."
            } catch {
                appModel.userFacingError = error.localizedDescription
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
                    .frame(width: 23, height: 23)
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
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.moonGold.opacity(0.10) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.moonGold.opacity(0.52) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(day.dateTitle), \(day.phaseNameKo), \(day.brightnessText)")
        .accessibilityHint("선택한 날짜의 월출과 월몰 시간 보기")
    }

    private var dayTextColor: Color {
        if isToday { return Color.moonBackground }
        return isSelected ? Color.moonGold : Color.moonText
    }
}

private struct SelectedMoonDayPanel: View {
    let day: MoonDay
    let addReminder: () -> Void
    let openPhotoMode: () -> Void

    var body: some View {
        GlassPanel(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 14) {
                        phaseGlyph
                        dayDescription
                        Spacer(minLength: 6)
                        phaseChip
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 14) {
                            phaseGlyph
                            dayDescription
                        }
                        phaseChip
                    }
                }

                Divider().background(.white.opacity(0.12))

                HStack(spacing: 12) {
                    DetailMetric(title: "월출", value: day.moonrise)
                    DetailMetric(title: "남중", value: day.transit)
                    DetailMetric(title: "월몰", value: day.moonset)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) { actionButtons }
                    VStack(alignment: .leading, spacing: 10) { actionButtons }
                }
            }
        }
    }

    private var phaseGlyph: some View {
        MoonPhaseGlyph(
            illumination: day.illumination,
            isWaxing: day.isWaxing,
            size: 68,
            isEmphasized: day.isMajorPhase
        )
    }

    private var dayDescription: some View {
        VStack(alignment: .leading, spacing: 5) {
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
        .lineLimit(1)
        .minimumScaleFactor(0.74)
    }

    private var phaseChip: some View {
        MoonChip(
            day.majorPhaseLabel ?? day.waxingText,
            symbolName: day.isWaxing ? "arrow.up.right" : "arrow.down.right",
            tint: day.isMajorPhase ? Color.moonGold : Color.moonAqua
        )
    }

    @ViewBuilder
    private var actionButtons: some View {
        Button(action: addReminder) {
            Label("월출 알림", systemImage: "bell.badge")
        }
        .buttonStyle(PillButtonStyle())

        Button(action: openPhotoMode) {
            Label("사진 모드", systemImage: "camera.fill")
        }
        .buttonStyle(SecondaryPillButtonStyle())
    }
}

private struct DetailMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.moonSubtext)

            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MoonCalendarView()
        .environmentObject(AppModel())
}
