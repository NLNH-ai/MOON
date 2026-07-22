import XCTest
@testable import OneulDal

final class OneulDalTests: XCTestCase {
    func testAstronomySnapshotUsesRequestedDateAndLocation() throws {
        let referenceDate = try date(year: 2026, month: 7, day: 2, hour: 12)
        let snapshot = MoonAstronomyService.snapshot(
            at: referenceDate,
            location: MoonLocationCatalog.seoul,
            use24HourTime: true
        )

        XCTAssertEqual(snapshot.location, MoonLocationCatalog.seoul)
        XCTAssertEqual(snapshot.today.day, 2)
        XCTAssertEqual(snapshot.currentMonthDays.count, 31)
        XCTAssertEqual(snapshot.previewDays.count, 7)
        XCTAssertTrue((0...100).contains(snapshot.today.illumination))
        XCTAssertGreaterThanOrEqual(snapshot.today.moonAge, 0)
    }

    func testAstronomyMonthIncludesAllMajorPhases() throws {
        let referenceDate = try date(year: 2026, month: 7, day: 2, hour: 12)
        let month = MoonAstronomyService.month(
            containing: referenceDate,
            location: MoonLocationCatalog.seoul,
            use24HourTime: true
        )
        let labels = Set(month.days.compactMap(\.majorPhaseLabel))

        XCTAssertTrue(labels.contains("삭"))
        XCTAssertTrue(labels.contains("상현"))
        XCTAssertTrue(labels.contains("보름"))
        XCTAssertTrue(labels.contains("하현"))
    }

    func testNextFullMoonIsInTheFuture() throws {
        let referenceDate = try date(year: 2026, month: 7, day: 2, hour: 12)
        let snapshot = MoonAstronomyService.snapshot(
            at: referenceDate,
            location: MoonLocationCatalog.seoul,
            use24HourTime: true
        )
        let fullMoon = try XCTUnwrap(snapshot.nextFullMoon)

        XCTAssertEqual(fullMoon.kind, .fullMoon)
        XCTAssertGreaterThan(fullMoon.date, referenceDate)
        XCTAssertFalse(fullMoon.dateText.isEmpty)
        XCTAssertFalse(fullMoon.countdownText.isEmpty)
    }

    func testVisibilityBeforeTransitShowsNextHighestPoint() throws {
        let day = try moonDay(
            moonriseHour: 13,
            moonriseMinute: 42,
            transitHour: 19,
            transitMinute: 20,
            moonsetHour: 0,
            moonsetMinute: 48
        )
        let summary = day.visibilitySummary(
            at: try date(year: 2026, month: 7, day: 2, hour: 18, minute: 30),
            calendar: seoulCalendar
        )

        XCTAssertEqual(summary.status, "지금 떠 있어요")
        XCTAssertEqual(summary.nextEvent, "19:20에 가장 높이 떠요")
    }

    func testVisibilityHandlesMoonsetAfterMidnight() throws {
        let day = try moonDay(
            moonriseHour: 13,
            moonriseMinute: 42,
            transitHour: 19,
            transitMinute: 20,
            moonsetHour: 0,
            moonsetMinute: 48
        )
        let summary = day.visibilitySummary(
            at: try date(year: 2026, month: 7, day: 2, hour: 0, minute: 30),
            calendar: seoulCalendar
        )

        XCTAssertEqual(summary.status, "지금 떠 있어요")
        XCTAssertEqual(summary.nextEvent, "00:48에 져요")
    }

    func testVisibilityGracefullyHandlesUnavailableEvents() throws {
        let day = MoonDay(
            date: try date(year: 2026, month: 7, day: 2),
            timeZoneIdentifier: "Asia/Seoul",
            use24HourTime: true,
            phaseNameKo: "달",
            phaseNameEn: "Moon",
            illumination: 50,
            moonAge: 7,
            isWaxing: true,
            isMajorPhase: false,
            majorPhaseLabel: nil,
            moonriseDate: nil,
            transitDate: nil,
            moonsetDate: nil
        )
        let summary = day.visibilitySummary(at: Date(), calendar: seoulCalendar)

        XCTAssertEqual(summary.status, "달 위치를 확인할 수 없어요")
    }

    func testNotificationPlannerCreatesOnlyFutureEnabledPlans() throws {
        let now = try date(year: 2026, month: 7, day: 2, hour: 12)
        let snapshot = MoonAstronomyService.snapshot(
            at: now,
            location: MoonLocationCatalog.seoul,
            use24HourTime: true
        )
        let preferences = MoonReminderPreferences(
            fullMoon: true,
            newMoon: false,
            quarters: false,
            moonrise: true
        )
        let plans = MoonNotificationPlanner.plans(
            snapshot: snapshot,
            preferences: preferences,
            now: now
        )

        XCTAssertFalse(plans.isEmpty)
        XCTAssertTrue(plans.allSatisfy { $0.fireDate > now })
        XCTAssertTrue(plans.allSatisfy { $0.id.hasPrefix("oneuldal.") })
        XCTAssertFalse(plans.contains(where: { $0.id.contains("new") }))
    }

    func testCityCatalogFallsBackToSeoul() {
        XCTAssertEqual(MoonLocationCatalog.city(id: "missing"), MoonLocationCatalog.seoul)
        XCTAssertNotEqual(MoonLocationCatalog.city(id: "busan"), MoonLocationCatalog.seoul)
    }

    func testMoonLightingGeometryMatchesKeyWaxingPhases() {
        let newMoon = MoonLightingGeometry.lightDirection(illumination: 0, isWaxing: true)
        let halfMoon = MoonLightingGeometry.lightDirection(illumination: 50, isWaxing: true)
        let fullMoon = MoonLightingGeometry.lightDirection(illumination: 100, isWaxing: true)

        XCTAssertEqual(newMoon.horizontal, 0, accuracy: 0.001)
        XCTAssertEqual(newMoon.depth, -1, accuracy: 0.001)
        XCTAssertEqual(halfMoon.horizontal, 1, accuracy: 0.001)
        XCTAssertEqual(halfMoon.depth, 0, accuracy: 0.001)
        XCTAssertEqual(fullMoon.horizontal, 0, accuracy: 0.001)
        XCTAssertEqual(fullMoon.depth, 1, accuracy: 0.001)
    }

    func testMoonLightingGeometryMirrorsWaningPhaseAndClampsInputs() {
        let waxing = MoonLightingGeometry.lightDirection(illumination: 37, isWaxing: true)
        let waning = MoonLightingGeometry.lightDirection(illumination: 37, isWaxing: false)
        let belowRange = MoonLightingGeometry.lightDirection(illumination: -20, isWaxing: true)
        let aboveRange = MoonLightingGeometry.lightDirection(illumination: 120, isWaxing: true)

        XCTAssertEqual(waxing.horizontal, -waning.horizontal, accuracy: 0.001)
        XCTAssertEqual(waxing.depth, waning.depth, accuracy: 0.001)
        let vectorLength = sqrt((waxing.horizontal * waxing.horizontal) + (waxing.depth * waxing.depth))
        XCTAssertEqual(vectorLength, 1, accuracy: 0.001)
        XCTAssertEqual(belowRange.depth, -1, accuracy: 0.001)
        XCTAssertEqual(aboveRange.depth, 1, accuracy: 0.001)
    }

    func testTodayLayoutCompressesGraduallyOnlyWhenTheViewportNeedsIt() {
        let compact = TodayLayoutMetrics(availableHeight: 620)
        let intermediate = TodayLayoutMetrics(availableHeight: 720)
        let roomy = TodayLayoutMetrics(availableHeight: 900)

        XCTAssertEqual(compact.compressionProgress, 1, accuracy: 0.001)
        XCTAssertGreaterThan(intermediate.compressionProgress, 0)
        XCTAssertLessThan(intermediate.compressionProgress, 1)
        XCTAssertEqual(roomy.compressionProgress, 0, accuracy: 0.001)

        XCTAssertEqual(compact.moonDiameter, MoonLayout.todayMinimumMoonDiameter, accuracy: 0.001)
        XCTAssertGreaterThan(intermediate.moonDiameter, compact.moonDiameter)
        XCTAssertLessThan(intermediate.moonDiameter, roomy.moonDiameter)
        XCTAssertEqual(roomy.moonDiameter, MoonLayout.todayMoonDiameter, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(compact.moonDiameter, 240)
        XCTAssertLessThanOrEqual(roomy.moonDiameter, 252)
        XCTAssertTrue((CGFloat(20)...CGFloat(24)).contains(MoonLayout.tabBarContentSpacing))
    }

    private var seoulCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }

    private func moonDay(
        moonriseHour: Int,
        moonriseMinute: Int,
        transitHour: Int,
        transitMinute: Int,
        moonsetHour: Int,
        moonsetMinute: Int
    ) throws -> MoonDay {
        MoonDay(
            date: try date(year: 2026, month: 7, day: 2),
            timeZoneIdentifier: "Asia/Seoul",
            use24HourTime: true,
            phaseNameKo: "상현망간의 달",
            phaseNameEn: "Waxing Gibbous",
            illumination: 63,
            moonAge: 9.8,
            isWaxing: true,
            isMajorPhase: false,
            majorPhaseLabel: nil,
            moonriseDate: try date(year: 2026, month: 7, day: 2, hour: moonriseHour, minute: moonriseMinute),
            transitDate: try date(year: 2026, month: 7, day: 2, hour: transitHour, minute: transitMinute),
            moonsetDate: try date(year: 2026, month: 7, day: 2, hour: moonsetHour, minute: moonsetMinute)
        )
    }

    private func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0
    ) throws -> Date {
        var components = DateComponents()
        components.calendar = seoulCalendar
        components.timeZone = seoulCalendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return try XCTUnwrap(components.date)
    }
}
