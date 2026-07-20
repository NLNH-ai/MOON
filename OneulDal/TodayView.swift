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
    @EnvironmentObject private var appModel: AppModel
    @State private var activeSheet: TodaySheet?

    private var today: MoonDay { appModel.snapshot.today }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                ZStack {
                    MoonBackground()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            topBar
                            moonHero(at: context.date)
                            if let nextFullMoon = appModel.nextFullMoon {
                                nextFullMoonLink(nextFullMoon)
                            }
                            monthPreview
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 10)
                        .padding(.bottom, MoonLayout.tabBarContentClearance)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .location:
                    LocationPickerSheet()
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
                    TodayLocationChip(locationName: appModel.selectedLocation.name)
                }
                .buttonStyle(.plain)
                .frame(width: MoonLayout.headerSideRailWidth, alignment: .leading)
                .accessibilityLabel("지역 \(appModel.selectedLocation.name)")

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
                .frame(width: MoonLayout.headerSideRailWidth, alignment: .trailing)
                .accessibilityLabel("설정")
            }
        }
        .frame(height: 46)
    }

    private func moonHero(at date: Date) -> some View {
        let visibility = today.visibilitySummary(at: date)

        return VStack(spacing: 16) {
            RealisticMoonView(
                illumination: today.illumination,
                isWaxing: today.isWaxing,
                size: MoonLayout.todayMoonDiameter
            )
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(today.dateTitle)
                        .font(.system(size: MoonLayout.todayDateTextSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.moonGold.opacity(0.78))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .layoutPriority(1)

                    Spacer(minLength: 4)

                    Label("밝기 \(today.illumination)%", systemImage: "sun.max.fill")
                        .font(.system(size: MoonLayout.todayBrightnessTextSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.moonGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .padding(.bottom, 8)

                Text(visibility.status)
                    .font(.system(size: MoonLayout.todayStatusTextSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.moonText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(visibility.nextEvent)
                    .font(.system(size: MoonLayout.todayNextEventTextSize, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.moonSubtext)
                    .padding(.top, 5)

                Text(today.plainLanguagePhaseName)
                    .font(.system(size: MoonLayout.todayPhaseTitleTextSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.moonSubtext.opacity(0.90))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
        }
    }

    private func nextFullMoonLink(_ nextFullMoon: MoonEventSummary) -> some View {
        Button {
            selectedTab = .calendar
        } label: {
            HStack(spacing: 8) {
                Text(nextFullMoon.title)
                    .foregroundStyle(Color.moonText)

                Text("·")
                    .foregroundStyle(Color.moonSubtext)

                Text(nextFullMoon.countdownText)
                    .foregroundStyle(Color.moonGold)

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.moonSubtext.opacity(0.72))
                    .accessibilityHidden(true)
            }
            .font(.system(size: MoonLayout.nextMoonLinkTextSize, weight: .semibold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(nextFullMoon.title), \(nextFullMoon.countdownText), \(nextFullMoon.dateText)")
        .accessibilityHint("달력에서 날짜 보기")
    }

    private var monthPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                ForEach(appModel.snapshot.previewDays) { moonDay in
                    WeekMoonCell(
                        day: moonDay,
                        isToday: appModel.calendar.isDate(moonDay.date, inSameDayAs: today.date)
                    )
                }
            }
        }
        .padding(.top, 10)
    }
}

private struct TodayLocationChip: View {
    let locationName: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.moonAqua.opacity(0.76))

            Text(locationName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.moonText.opacity(0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .padding(.horizontal, 11)
        .frame(height: 32)
        .background(Color.moonSurface2.opacity(0.72), in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.moonAqua.opacity(0.18), lineWidth: 1)
        )
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


#Preview {
    TodayView(selectedTab: .constant(.today))
        .environmentObject(AppModel())
}
