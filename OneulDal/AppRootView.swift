import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case calendar
    case notifications

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            return "오늘달"
        case .calendar:
            return "달력"
        case .notifications:
            return "알림"
        }
    }

    var symbolName: String {
        switch self {
        case .today:
            return "moon.fill"
        case .calendar:
            return "calendar"
        case .notifications:
            return "bell"
        }
    }
}

struct AppRootView: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab)
                .tabItem {
                    Label(AppTab.today.title, systemImage: AppTab.today.symbolName)
                }
                .tag(AppTab.today)

            MoonCalendarView()
                .tabItem {
                    Label(AppTab.calendar.title, systemImage: AppTab.calendar.symbolName)
                }
                .tag(AppTab.calendar)

            MoonNotificationsView()
                .tabItem {
                    Label(AppTab.notifications.title, systemImage: AppTab.notifications.symbolName)
                }
                .tag(AppTab.notifications)
        }
        .tint(Color.moonGold)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AppRootView()
}
