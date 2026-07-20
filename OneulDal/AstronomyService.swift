import Foundation
import SwiftAA

enum MoonAstronomyService {
    private struct PhaseMoment {
        let kind: MoonEventKind
        let date: Date
    }

    private struct DailySkyEvents {
        let rises: [Date]
        let transits: [Date]
        let sets: [Date]
    }

    static func snapshot(
        at referenceDate: Date,
        location: MoonLocation,
        use24HourTime: Bool
    ) -> MoonSnapshot {
        let calendar = calendar(for: location)
        let month = month(containing: referenceDate, location: location, use24HourTime: use24HourTime)
        let todayStart = calendar.startOfDay(for: referenceDate)
        let previewEnd = calendar.date(byAdding: .day, value: 7, to: todayStart) ?? todayStart.addingTimeInterval(7 * 86_400)
        let previewDays = days(
            in: DateInterval(start: todayStart, end: previewEnd),
            location: location,
            use24HourTime: use24HourTime
        )
        let today = previewDays.first ?? day(
            at: referenceDate,
            location: location,
            use24HourTime: use24HourTime
        )

        return MoonSnapshot(
            generatedAt: referenceDate,
            location: location,
            today: today,
            currentMonthStart: month.start,
            currentMonthDays: month.days,
            previewDays: previewDays,
            nextEvents: nextPhaseEvents(after: referenceDate, location: location)
        )
    }

    static func month(
        containing date: Date,
        location: MoonLocation,
        use24HourTime: Bool
    ) -> (start: Date, days: [MoonDay]) {
        let calendar = calendar(for: location)
        let interval = calendar.dateInterval(of: .month, for: date)
            ?? DateInterval(start: calendar.startOfDay(for: date), duration: 31 * 86_400)

        return (
            start: interval.start,
            days: days(in: interval, location: location, use24HourTime: use24HourTime)
        )
    }

    static func day(
        at date: Date,
        location: MoonLocation,
        use24HourTime: Bool
    ) -> MoonDay {
        let calendar = calendar(for: location)
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        return days(
            in: DateInterval(start: start, end: end),
            location: location,
            use24HourTime: use24HourTime
        ).first!
    }

    private static func days(
        in interval: DateInterval,
        location: MoonLocation,
        use24HourTime: Bool
    ) -> [MoonDay] {
        let calendar = calendar(for: location)
        let phaseMoments = phaseMoments(around: interval)
        let skyEvents = skyEvents(around: interval, location: location)
        var result: [MoonDay] = []
        var dayStart = calendar.startOfDay(for: interval.start)

        while dayStart < interval.end {
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)
                ?? dayStart.addingTimeInterval(86_400)
            let observationDate = calendar.date(byAdding: .hour, value: 12, to: dayStart)
                ?? dayStart.addingTimeInterval(43_200)
            let majorPhase = phaseMoments.first(where: { $0.date >= dayStart && $0.date < dayEnd })
            let previousNewMoon = phaseMoments
                .last(where: { $0.kind == .newMoon && $0.date <= observationDate })?.date
                ?? Moon(julianDay: JulianDay(observationDate)).time(of: .newMoon, forward: false, mean: false).date
            let fullMoonAfterNew = phaseMoments
                .first(where: { $0.kind == .fullMoon && $0.date > previousNewMoon })?.date
                ?? Moon(julianDay: JulianDay(previousNewMoon)).time(of: .fullMoon, forward: true, mean: false).date
            let isWaxing = observationDate < fullMoonAfterNew
            let moonAge = max(0, observationDate.timeIntervalSince(previousNewMoon) / 86_400)
            let moon = Moon(julianDay: JulianDay(observationDate))
            let illumination = min(100, max(0, Int((moon.illuminatedFraction() * 100).rounded())))
            let names = phaseNames(illumination: illumination, isWaxing: isWaxing, majorPhase: majorPhase?.kind)
            let events = events(on: dayStart, before: dayEnd, from: skyEvents)

            result.append(
                MoonDay(
                    date: dayStart,
                    timeZoneIdentifier: location.timeZoneIdentifier,
                    use24HourTime: use24HourTime,
                    phaseNameKo: names.korean,
                    phaseNameEn: names.english,
                    illumination: illumination,
                    moonAge: moonAge,
                    isWaxing: isWaxing,
                    isMajorPhase: majorPhase != nil,
                    majorPhaseLabel: majorPhase?.kind.phaseLabel,
                    moonriseDate: events.rises.first,
                    transitDate: events.transits.first,
                    moonsetDate: events.sets.first
                )
            )

            dayStart = dayEnd
        }

        return result
    }

    private static func nextPhaseEvents(after date: Date, location: MoonLocation) -> [MoonEventSummary] {
        let calendar = calendar(for: location)
        let moon = Moon(julianDay: JulianDay(date))
        let kinds: [MoonEventKind] = [.fullMoon, .newMoon, .firstQuarter, .lastQuarter]

        return kinds.map { kind in
            let eventDate = moon.time(of: swiftPhase(for: kind), forward: true, mean: false).date
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.calendar = calendar
            formatter.timeZone = location.timeZone
            formatter.dateFormat = "M월 d일 EEEE"

            let start = calendar.startOfDay(for: date)
            let eventStart = calendar.startOfDay(for: eventDate)
            let daysUntil = max(0, calendar.dateComponents([.day], from: start, to: eventStart).day ?? 0)
            let countdown: String
            switch daysUntil {
            case 0:
                countdown = "오늘"
            case 1:
                countdown = "내일"
            default:
                countdown = "\(daysUntil)일 뒤"
            }

            return MoonEventSummary(
                kind: kind,
                date: eventDate,
                dateText: formatter.string(from: eventDate),
                countdownText: countdown
            )
        }
    }

    private static func phaseMoments(around interval: DateInterval) -> [PhaseMoment] {
        let searchStart = interval.start.addingTimeInterval(-35 * 86_400)
        let searchEnd = interval.end.addingTimeInterval(35 * 86_400)
        var moments: [PhaseMoment] = []

        for kind in MoonEventKind.allCases {
            var cursor = searchStart

            while cursor < searchEnd {
                let eventDate = Moon(julianDay: JulianDay(cursor))
                    .time(of: swiftPhase(for: kind), forward: true, mean: false)
                    .date

                guard eventDate < searchEnd else { break }
                moments.append(PhaseMoment(kind: kind, date: eventDate))
                cursor = eventDate.addingTimeInterval(3_600)
            }
        }

        return moments.sorted(by: { $0.date < $1.date })
    }

    private static func skyEvents(around interval: DateInterval, location: MoonLocation) -> DailySkyEvents {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let coordinates = GeographicCoordinates(
            positivelyWestwardLongitude: Degree(-location.longitude),
            latitude: Degree(location.latitude)
        )
        let searchStart = utcCalendar.startOfDay(for: interval.start.addingTimeInterval(-86_400))
        let searchEnd = interval.end.addingTimeInterval(2 * 86_400)
        var date = searchStart
        var rises: [Date] = []
        var transits: [Date] = []
        var sets: [Date] = []

        while date < searchEnd {
            let times = Moon(julianDay: JulianDay(date)).riseTransitSetTimes(for: coordinates)
            if let rise = times.riseTime?.date { rises.append(rise) }
            if let transit = times.transitTime?.date { transits.append(transit) }
            if let set = times.setTime?.date { sets.append(set) }
            date = utcCalendar.date(byAdding: .day, value: 1, to: date)
                ?? date.addingTimeInterval(86_400)
        }

        return DailySkyEvents(
            rises: uniqueSorted(rises),
            transits: uniqueSorted(transits),
            sets: uniqueSorted(sets)
        )
    }

    private static func events(
        on start: Date,
        before end: Date,
        from events: DailySkyEvents
    ) -> DailySkyEvents {
        DailySkyEvents(
            rises: events.rises.filter { $0 >= start && $0 < end },
            transits: events.transits.filter { $0 >= start && $0 < end },
            sets: events.sets.filter { $0 >= start && $0 < end }
        )
    }

    private static func uniqueSorted(_ dates: [Date]) -> [Date] {
        var seen = Set<Int64>()
        return dates
            .sorted()
            .filter { seen.insert(Int64($0.timeIntervalSince1970.rounded())).inserted }
    }

    private static func phaseNames(
        illumination: Int,
        isWaxing: Bool,
        majorPhase: MoonEventKind?
    ) -> (korean: String, english: String) {
        if let majorPhase {
            switch majorPhase {
            case .newMoon:
                return ("삭", "New Moon")
            case .firstQuarter:
                return ("상현달", "First Quarter")
            case .fullMoon:
                return ("보름달", "Full Moon")
            case .lastQuarter:
                return ("하현달", "Last Quarter")
            }
        }

        if illumination <= 2 {
            return ("삭 무렵", "New Moon")
        }

        if illumination >= 98 {
            return ("보름달 무렵", "Full Moon")
        }

        if isWaxing {
            return illumination < 50
                ? ("초승달", "Waxing Crescent")
                : ("상현망간의 달", "Waxing Gibbous")
        }

        return illumination > 50
            ? ("하현망간의 달", "Waning Gibbous")
            : ("그믐달", "Waning Crescent")
    }

    private static func swiftPhase(for kind: MoonEventKind) -> MoonPhase {
        switch kind {
        case .newMoon:
            return .newMoon
        case .firstQuarter:
            return .firstQuarter
        case .fullMoon:
            return .fullMoon
        case .lastQuarter:
            return .lastQuarter
        }
    }

    static func calendar(for location: MoonLocation) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = location.timeZone
        return calendar
    }
}
