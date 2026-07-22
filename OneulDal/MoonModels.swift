import Foundation

struct MoonVisibilitySummary: Equatable, Sendable {
    let status: String
    let nextEvent: String
}

struct MoonLocation: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String
    let isCurrentLocation: Bool

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }
}

enum MoonLocationCatalog {
    static let seoul = MoonLocation(
        id: "seoul",
        name: "서울",
        latitude: 37.5665,
        longitude: 126.9780,
        timeZoneIdentifier: "Asia/Seoul",
        isCurrentLocation: false
    )

    static let cities: [MoonLocation] = [
        seoul,
        .init(id: "busan", name: "부산", latitude: 35.1796, longitude: 129.0756, timeZoneIdentifier: "Asia/Seoul", isCurrentLocation: false),
        .init(id: "jeju", name: "제주", latitude: 33.4996, longitude: 126.5312, timeZoneIdentifier: "Asia/Seoul", isCurrentLocation: false),
        .init(id: "daejeon", name: "대전", latitude: 36.3504, longitude: 127.3845, timeZoneIdentifier: "Asia/Seoul", isCurrentLocation: false),
        .init(id: "tokyo", name: "도쿄", latitude: 35.6762, longitude: 139.6503, timeZoneIdentifier: "Asia/Tokyo", isCurrentLocation: false)
    ]

    static func city(id: String?) -> MoonLocation {
        cities.first(where: { $0.id == id }) ?? seoul
    }

    static func current(latitude: Double, longitude: Double) -> MoonLocation {
        MoonLocation(
            id: "current",
            name: "현재 위치",
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: TimeZone.current.identifier,
            isCurrentLocation: true
        )
    }
}

enum MoonEventKind: String, CaseIterable, Codable, Sendable {
    case newMoon
    case firstQuarter
    case fullMoon
    case lastQuarter

    var title: String {
        switch self {
        case .newMoon:
            return "다음 삭"
        case .firstQuarter:
            return "다음 상현"
        case .fullMoon:
            return "다음 보름달"
        case .lastQuarter:
            return "다음 하현"
        }
    }

    var phaseLabel: String {
        switch self {
        case .newMoon:
            return "삭"
        case .firstQuarter:
            return "상현"
        case .fullMoon:
            return "보름"
        case .lastQuarter:
            return "하현"
        }
    }
}

struct MoonEventSummary: Identifiable, Equatable, Sendable {
    let kind: MoonEventKind
    let date: Date
    let dateText: String
    let countdownText: String

    var id: String { kind.rawValue }
    var title: String { kind.title }
}

struct MoonDay: Identifiable, Equatable, Sendable {
    let date: Date
    let timeZoneIdentifier: String
    let use24HourTime: Bool
    let phaseNameKo: String
    let phaseNameEn: String
    let illumination: Int
    let moonAge: Double
    let isWaxing: Bool
    let isMajorPhase: Bool
    let majorPhaseLabel: String?
    let moonriseDate: Date?
    let transitDate: Date?
    let moonsetDate: Date?

    var id: Date { date }

    var day: Int {
        calendar.component(.day, from: date)
    }

    var weekday: String {
        formattedDate("EEEE")
    }

    var brightnessText: String {
        "밝기 \(illumination)%"
    }

    var moonAgeText: String {
        "달령 \(String(format: "%.1f", moonAge))일"
    }

    var waxingText: String {
        isWaxing ? "차는 중" : "기우는 중"
    }

    var plainLanguagePhaseName: String {
        switch phaseNameEn {
        case "Waxing Crescent":
            return "초승달로 차오르는 중"
        case "Waxing Gibbous":
            return "보름달로 차오르는 중"
        case "Waning Gibbous":
            return "보름달에서 기우는 중"
        case "Waning Crescent":
            return "그믐달로 기우는 중"
        case "Full Moon":
            return "보름달"
        case "New Moon":
            return "달이 거의 보이지 않아요"
        case "First Quarter":
            return "반달로 차오르는 중"
        case "Last Quarter":
            return "반달로 기우는 중"
        default:
            return isWaxing ? "달이 차오르는 중" : "달이 기우는 중"
        }
    }

    var dateTitle: String {
        formattedDate("M월 d일 EEEE")
    }

    var moonrise: String { formattedTime(moonriseDate) }
    var transit: String { formattedTime(transitDate) }
    var moonset: String { formattedTime(moonsetDate) }

    func visibilitySummary(
        at date: Date,
        calendar suppliedCalendar: Calendar? = nil
    ) -> MoonVisibilitySummary {
        var eventCalendar = suppliedCalendar ?? calendar
        eventCalendar.timeZone = calendar.timeZone

        let currentMinutes = minutesSinceMidnight(from: date, calendar: eventCalendar)
        let riseMinutes = moonriseDate.map {
            minutesSinceMidnight(from: $0, calendar: eventCalendar)
        }
        let transitMinutes = transitDate.map {
            minutesSinceMidnight(from: $0, calendar: eventCalendar)
        }
        let setMinutes = moonsetDate.map {
            minutesSinceMidnight(from: $0, calendar: eventCalendar)
        }

        guard riseMinutes != nil || setMinutes != nil else {
            return MoonVisibilitySummary(
                status: "달 뜨는 시간을 불러오지 못했어요",
                nextEvent: "잠시 후 다시 확인해 주세요"
            )
        }

        guard let riseMinutes else {
            guard let setMinutes, currentMinutes < setMinutes else {
                return MoonVisibilitySummary(
                    status: "오늘 달은 졌어요",
                    nextEvent: "다음 월출 시간은 달력에서 확인해 주세요"
                )
            }

            return MoonVisibilitySummary(
                status: "지금 달이 떠 있어요",
                nextEvent: "\(moonset)에 져요"
            )
        }

        let transitInCycle = transitMinutes.map { minutes in
            minutes < riseMinutes ? minutes + 1_440 : minutes
        }
        let setInCycle = setMinutes.map { minutes in
            minutes < riseMinutes ? minutes + 1_440 : minutes
        }
        let currentInCycle: Int
        if let setMinutes, let setInCycle,
           setInCycle > 1_440,
           currentMinutes < setMinutes {
            currentInCycle = currentMinutes + 1_440
        } else {
            currentInCycle = currentMinutes
        }

        if currentInCycle < riseMinutes {
            return MoonVisibilitySummary(
                status: "달은 오늘 \(moonrise)에 떠요",
                nextEvent: "지금은 지평선 아래에 있어요"
            )
        }

        if let setInCycle, currentInCycle >= setInCycle {
            return MoonVisibilitySummary(
                status: "오늘 달은 졌어요",
                nextEvent: "다음 월출 시간은 달력에서 확인해 주세요"
            )
        }

        if let transitInCycle, currentInCycle < transitInCycle {
            return MoonVisibilitySummary(
                status: "지금 달이 떠 있어요",
                nextEvent: "\(transit)에 가장 높이 떠요"
            )
        }

        if let setInCycle, currentInCycle < setInCycle {
            return MoonVisibilitySummary(
                status: "지금 달이 떠 있어요",
                nextEvent: "\(moonset)에 져요"
            )
        }

        return MoonVisibilitySummary(
            status: "지금 달이 떠 있어요",
            nextEvent: "현재 위치 기준으로 표시하고 있어요"
        )
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        return calendar
    }

    private func formattedDate(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date?) -> String {
        guard let date else { return "정보 없음" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = use24HourTime ? "HH:mm" : "a h:mm"
        return formatter.string(from: date)
    }

    private func minutesSinceMidnight(from date: Date, calendar: Calendar) -> Int {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}

struct MoonSnapshot: Equatable, Sendable {
    let generatedAt: Date
    let location: MoonLocation
    let today: MoonDay
    let currentMonthStart: Date
    let currentMonthDays: [MoonDay]
    let previewDays: [MoonDay]
    let nextEvents: [MoonEventSummary]

    var nextFullMoon: MoonEventSummary? {
        nextEvents.first(where: { $0.kind == .fullMoon })
    }
}
