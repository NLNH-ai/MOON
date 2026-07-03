import SwiftUI
import UIKit

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
            return "bell.fill"
        }
    }
}

struct AppRootView: View {
    @State private var selectedTab: AppTab = .today

    init() {
        Self.configureTabBarAppearance()
    }

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

    private static func configureTabBarAppearance() {
        let selectedTabItemFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let normalTabItemFont = UIFont.systemFont(ofSize: 13, weight: .medium)
        let selectedColor = UIColor(red: 0.905, green: 0.843, blue: 0.604, alpha: 1)
        let normalColor = UIColor(red: 0.667, green: 0.706, blue: 0.773, alpha: 0.64)
        let tabBackground = UIColor(red: 0.030, green: 0.034, blue: 0.047, alpha: 0.86)

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = tabBackground
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.06)

        appearance.stackedLayoutAppearance = tabItemAppearance(
            selectedColor: selectedColor,
            normalColor: normalColor,
            selectedFont: selectedTabItemFont,
            normalFont: normalTabItemFont
        )
        appearance.inlineLayoutAppearance = tabItemAppearance(
            selectedColor: selectedColor,
            normalColor: normalColor,
            selectedFont: selectedTabItemFont,
            normalFont: normalTabItemFont
        )
        appearance.compactInlineLayoutAppearance = tabItemAppearance(
            selectedColor: selectedColor,
            normalColor: normalColor,
            selectedFont: selectedTabItemFont,
            normalFont: normalTabItemFont
        )

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }

    private static func tabItemAppearance(
        selectedColor: UIColor,
        normalColor: UIColor,
        selectedFont: UIFont,
        normalFont: UIFont
    ) -> UITabBarItemAppearance {
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = normalColor
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: normalFont
        ]
        itemAppearance.selected.iconColor = selectedColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: selectedFont
        ]
        return itemAppearance
    }
}

#Preview {
    AppRootView()
}
