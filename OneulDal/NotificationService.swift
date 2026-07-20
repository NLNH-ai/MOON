import Foundation
import UserNotifications

enum MoonReminderKind: String, CaseIterable, Codable, Sendable {
    case fullMoon
    case newMoon
    case quarters
    case moonrise

    var title: String {
        switch self {
        case .fullMoon:
            return "보름달"
        case .newMoon:
            return "삭"
        case .quarters:
            return "상현 · 하현"
        case .moonrise:
            return "월출"
        }
    }
}

struct MoonReminderPreferences: Equatable, Sendable {
    var fullMoon: Bool
    var newMoon: Bool
    var quarters: Bool
    var moonrise: Bool

    var enabledCount: Int {
        [fullMoon, newMoon, quarters, moonrise].filter { $0 }.count
    }

    subscript(kind: MoonReminderKind) -> Bool {
        get {
            switch kind {
            case .fullMoon: return fullMoon
            case .newMoon: return newMoon
            case .quarters: return quarters
            case .moonrise: return moonrise
            }
        }
        set {
            switch kind {
            case .fullMoon: fullMoon = newValue
            case .newMoon: newMoon = newValue
            case .quarters: quarters = newValue
            case .moonrise: moonrise = newValue
            }
        }
    }
}

struct MoonNotificationPlan: Identifiable, Equatable, Sendable {
    let id: String
    let fireDate: Date
    let title: String
    let body: String
}

enum MoonNotificationPlanner {
    static func plans(
        snapshot: MoonSnapshot,
        preferences: MoonReminderPreferences,
        now: Date
    ) -> [MoonNotificationPlan] {
        var plans: [MoonNotificationPlan] = []

        if preferences.fullMoon,
           let fullMoon = snapshot.nextEvents.first(where: { $0.kind == .fullMoon }) {
            let offsets = [
                (days: -3, label: "3일 뒤 보름달이에요"),
                (days: -1, label: "내일 보름달이에요"),
                (days: 0, label: "오늘 보름달이에요")
            ]

            for offset in offsets {
                let fireDate = fullMoon.date.addingTimeInterval(Double(offset.days) * 86_400)
                guard fireDate > now else { continue }
                plans.append(
                    MoonNotificationPlan(
                        id: identifier(prefix: "full", date: fireDate),
                        fireDate: fireDate,
                        title: offset.label,
                        body: "\(snapshot.location.name)에서 달이 가장 둥글게 보이는 때를 확인해 보세요."
                    )
                )
            }
        }

        if preferences.newMoon,
           let newMoon = snapshot.nextEvents.first(where: { $0.kind == .newMoon }),
           newMoon.date > now {
            plans.append(
                MoonNotificationPlan(
                    id: identifier(prefix: "new", date: newMoon.date),
                    fireDate: newMoon.date,
                    title: "오늘은 삭이에요",
                    body: "달빛이 적어 별을 관측하기 좋은 밤입니다."
                )
            )
        }

        if preferences.quarters {
            for kind in [MoonEventKind.firstQuarter, .lastQuarter] {
                guard
                    let event = snapshot.nextEvents.first(where: { $0.kind == kind }),
                    event.date > now
                else { continue }

                plans.append(
                    MoonNotificationPlan(
                        id: identifier(prefix: kind.rawValue, date: event.date),
                        fireDate: event.date,
                        title: "오늘은 \(kind.phaseLabel)이에요",
                        body: "달의 한 달 흐름이 반을 지났습니다."
                    )
                )
            }
        }

        if preferences.moonrise {
            for day in snapshot.previewDays {
                guard let moonrise = day.moonriseDate else { continue }
                let fireDate = moonrise.addingTimeInterval(-3_600)
                guard fireDate > now else { continue }

                plans.append(
                    MoonNotificationPlan(
                        id: identifier(prefix: "rise", date: moonrise),
                        fireDate: fireDate,
                        title: "한 시간 뒤 달이 떠요",
                        body: "\(day.moonrise)에 \(snapshot.location.name)에서 월출이 시작됩니다."
                    )
                )
            }
        }

        return plans.sorted(by: { $0.fireDate < $1.fireDate })
    }

    static func oneOffMoonrisePlan(for day: MoonDay, now: Date) -> MoonNotificationPlan? {
        guard let moonrise = day.moonriseDate else { return nil }
        let preferredDate = moonrise.addingTimeInterval(-3_600)
        let fireDate = preferredDate > now ? preferredDate : moonrise
        guard fireDate > now else { return nil }

        return MoonNotificationPlan(
            id: identifier(prefix: "manual-rise", date: moonrise),
            fireDate: fireDate,
            title: preferredDate > now ? "한 시간 뒤 달이 떠요" : "곧 달이 떠요",
            body: "\(day.dateTitle) \(day.moonrise) 월출 알림입니다."
        )
    }

    private static func identifier(prefix: String, date: Date) -> String {
        "oneuldal.\(prefix).\(Int(date.timeIntervalSince1970))"
    }
}

enum MoonNotificationAuthorization: Equatable, Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    var allowsScheduling: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        }
    }

    var displayText: String {
        switch self {
        case .notDetermined:
            return "요청 전"
        case .denied:
            return "차단됨"
        case .authorized:
            return "허용됨"
        case .provisional:
            return "조용히 허용"
        case .ephemeral:
            return "임시 허용"
        }
    }
}

protocol MoonNotificationScheduling {
    func authorizationStatus() async -> MoonNotificationAuthorization
    func requestAuthorization() async throws -> Bool
    func replaceScheduledNotifications(with plans: [MoonNotificationPlan], timeZone: TimeZone) async throws
    func schedule(_ plan: MoonNotificationPlan, timeZone: TimeZone) async throws
}

final class MoonNotificationService: MoonNotificationScheduling {
    private let center: UNUserNotificationCenter
    private let managedPrefix = "oneuldal."

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func authorizationStatus() async -> MoonNotificationAuthorization {
        let settings = await notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        @unknown default:
            return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func replaceScheduledNotifications(
        with plans: [MoonNotificationPlan],
        timeZone: TimeZone
    ) async throws {
        let pending = await pendingRequests()
        let managedIdentifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(managedPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: managedIdentifiers)

        for plan in plans.prefix(48) {
            try await schedule(plan, timeZone: timeZone)
        }
    }

    func schedule(_ plan: MoonNotificationPlan, timeZone: TimeZone) async throws {
        let content = UNMutableNotificationContent()
        content.title = plan.title
        content.body = plan.body
        content.sound = .default

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: plan.fireDate)
        components.timeZone = timeZone
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: plan.id, content: content, trigger: trigger)
        try await center.add(request)
    }

    private func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
}
