import Foundation

struct MoonVisibilitySummary: Equatable {
    let status: String
    let nextEvent: String
}

struct MoonDay: Identifiable, Equatable {
    let day: Int
    let weekday: String
    let phaseNameKo: String
    let phaseNameEn: String
    let illumination: Int
    let moonAge: Double
    let isWaxing: Bool
    let isMajorPhase: Bool
    let majorPhaseLabel: String?
    let moonrise: String
    let transit: String
    let moonset: String

    var id: Int { day }

    var brightnessText: String {
        "밝기 \(illumination)%"
    }

    var moonAgeText: String {
        "달령 \(String(format: "%.1f", moonAge))일"
    }

    var waxingText: String {
        isWaxing ? "지금 차는 중" : "지금 기우는 중"
    }

    var plainLanguagePhaseName: String {
        switch phaseNameEn {
        case "Waxing Gibbous":
            return "보름달로 차오르는 중"
        case "Waning Gibbous":
            return "보름달에서 기우는 중"
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
        "7월 \(day)일 \(weekday)"
    }

    func visibilitySummary(
        at date: Date,
        calendar: Calendar = .current
    ) -> MoonVisibilitySummary {
        guard
            let riseMinutes = minutesSinceMidnight(from: moonrise),
            let transitMinutes = minutesSinceMidnight(from: transit),
            let setMinutes = minutesSinceMidnight(from: moonset)
        else {
            return MoonVisibilitySummary(
                status: "달 위치를 확인할 수 없어요",
                nextEvent: "시간 정보를 다시 확인해 주세요"
            )
        }

        let components = calendar.dateComponents([.hour, .minute], from: date)
        let currentMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        let transitInCycle = transitMinutes < riseMinutes ? transitMinutes + 1_440 : transitMinutes
        let setInCycle = setMinutes < riseMinutes ? setMinutes + 1_440 : setMinutes
        let currentInCycle = setInCycle > 1_440 && currentMinutes < setMinutes
            ? currentMinutes + 1_440
            : currentMinutes

        if currentInCycle < riseMinutes {
            return MoonVisibilitySummary(
                status: "지금은 떠 있지 않아요",
                nextEvent: "\(moonrise)에 떠요"
            )
        }

        if currentInCycle < transitInCycle {
            return MoonVisibilitySummary(
                status: "지금 떠 있어요",
                nextEvent: "\(transit)에 가장 높이 떠요"
            )
        }

        if currentInCycle < setInCycle {
            return MoonVisibilitySummary(
                status: "지금 떠 있어요",
                nextEvent: "\(moonset)에 져요"
            )
        }

        return MoonVisibilitySummary(
            status: "오늘은 졌어요",
            nextEvent: "내일 \(moonrise)에 떠요"
        )
    }

    private func minutesSinceMidnight(from time: String) -> Int? {
        let parts = time.split(separator: ":")

        guard
            parts.count == 2,
            let hour = Int(parts[0]),
            let minute = Int(parts[1]),
            (0..<24).contains(hour),
            (0..<60).contains(minute)
        else {
            return nil
        }

        return hour * 60 + minute
    }
}

struct MoonEventSummary: Identifiable, Equatable {
    let id: String
    let title: String
    let dateText: String
    let countdownText: String
}

enum MoonFixtures {
    static let today = MoonDay(
        day: 2,
        weekday: "목요일",
        phaseNameKo: "상현망간의 달",
        phaseNameEn: "Waxing Gibbous",
        illumination: 63,
        moonAge: 9.8,
        isWaxing: true,
        isMajorPhase: false,
        majorPhaseLabel: nil,
        moonrise: "13:42",
        transit: "19:20",
        moonset: "00:48"
    )

    static let nextFullMoon = MoonEventSummary(
        id: "full",
        title: "다음 보름달",
        dateText: "7월 7일",
        countdownText: "5일 뒤"
    )

    static let nextEvents: [MoonEventSummary] = [
        nextFullMoon,
        .init(id: "new", title: "다음 삭", dateText: "7월 21일", countdownText: "19일 뒤"),
        .init(id: "first", title: "상현", dateText: "8월 1일", countdownText: "30일 뒤"),
        .init(id: "last", title: "하현", dateText: "7월 14일", countdownText: "12일 뒤")
    ]

    static let calendarDays: [MoonDay] = [
        .init(day: 1, weekday: "수요일", phaseNameKo: "상현망간의 달", phaseNameEn: "Waxing Gibbous", illumination: 58, moonAge: 8.8, isWaxing: true, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "12:36", transit: "18:31", moonset: "00:12"),
        today,
        .init(day: 3, weekday: "금요일", phaseNameKo: "상현망간의 달", phaseNameEn: "Waxing Gibbous", illumination: 70, moonAge: 10.8, isWaxing: true, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "14:48", transit: "20:06", moonset: "01:20"),
        .init(day: 4, weekday: "토요일", phaseNameKo: "상현망간의 달", phaseNameEn: "Waxing Gibbous", illumination: 78, moonAge: 11.8, isWaxing: true, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "15:51", transit: "20:50", moonset: "01:56"),
        .init(day: 5, weekday: "일요일", phaseNameKo: "상현망간의 달", phaseNameEn: "Waxing Gibbous", illumination: 86, moonAge: 12.8, isWaxing: true, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "16:51", transit: "21:32", moonset: "02:35"),
        .init(day: 6, weekday: "월요일", phaseNameKo: "보름달 직전", phaseNameEn: "Waxing Gibbous", illumination: 94, moonAge: 13.8, isWaxing: true, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "17:49", transit: "22:15", moonset: "03:18"),
        .init(day: 7, weekday: "화요일", phaseNameKo: "보름달", phaseNameEn: "Full Moon", illumination: 100, moonAge: 14.8, isWaxing: false, isMajorPhase: true, majorPhaseLabel: "보름", moonrise: "19:10", transit: "00:38", moonset: "05:49"),
        .init(day: 8, weekday: "수요일", phaseNameKo: "하현망간의 달", phaseNameEn: "Waning Gibbous", illumination: 98, moonAge: 15.8, isWaxing: false, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "20:05", transit: "01:24", moonset: "06:33"),
        .init(day: 9, weekday: "목요일", phaseNameKo: "하현망간의 달", phaseNameEn: "Waning Gibbous", illumination: 92, moonAge: 16.8, isWaxing: false, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "20:55", transit: "02:09", moonset: "07:20"),
        .init(day: 10, weekday: "금요일", phaseNameKo: "하현망간의 달", phaseNameEn: "Waning Gibbous", illumination: 84, moonAge: 17.8, isWaxing: false, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "21:39", transit: "02:54", moonset: "08:09"),
        .init(day: 11, weekday: "토요일", phaseNameKo: "하현망간의 달", phaseNameEn: "Waning Gibbous", illumination: 75, moonAge: 18.8, isWaxing: false, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "22:18", transit: "03:38", moonset: "09:00"),
        .init(day: 12, weekday: "일요일", phaseNameKo: "하현망간의 달", phaseNameEn: "Waning Gibbous", illumination: 64, moonAge: 19.8, isWaxing: false, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "22:53", transit: "04:21", moonset: "09:52"),
        .init(day: 13, weekday: "월요일", phaseNameKo: "하현달 직전", phaseNameEn: "Waning Gibbous", illumination: 53, moonAge: 20.8, isWaxing: false, isMajorPhase: false, majorPhaseLabel: nil, moonrise: "23:25", transit: "05:04", moonset: "10:45"),
        .init(day: 14, weekday: "화요일", phaseNameKo: "하현달", phaseNameEn: "Last Quarter", illumination: 48, moonAge: 21.8, isWaxing: false, isMajorPhase: true, majorPhaseLabel: "하현", moonrise: "23:56", transit: "05:48", moonset: "11:39"),
        .init(day: 21, weekday: "화요일", phaseNameKo: "삭", phaseNameEn: "New Moon", illumination: 0, moonAge: 0.0, isWaxing: true, isMajorPhase: true, majorPhaseLabel: "삭", moonrise: "05:11", transit: "12:22", moonset: "19:28"),
        .init(day: 29, weekday: "수요일", phaseNameKo: "상현달", phaseNameEn: "First Quarter", illumination: 51, moonAge: 7.4, isWaxing: true, isMajorPhase: true, majorPhaseLabel: "상현", moonrise: "12:04", transit: "18:05", moonset: "23:52")
    ]

    static func day(for day: Int) -> MoonDay {
        calendarDays.first(where: { $0.day == day }) ?? MoonDay(
            day: day,
            weekday: "수요일",
            phaseNameKo: "달",
            phaseNameEn: "Moon",
            illumination: max(0, min(100, 100 - abs(15 - day) * 6)),
            moonAge: Double(day % 29),
            isWaxing: day < 15 || day > 21,
            isMajorPhase: false,
            majorPhaseLabel: nil,
            moonrise: "13:42",
            transit: "19:20",
            moonset: "00:48"
        )
    }
}
