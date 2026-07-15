import XCTest
@testable import OneulDal

final class OneulDalTests: XCTestCase {
    func testTodaySummaryUsesPlainLanguage() {
        let today = MoonFixtures.today

        XCTAssertEqual(today.phaseNameKo, "상현망간의 달")
        XCTAssertEqual(today.plainLanguagePhaseName, "보름달로 차오르는 중")
        XCTAssertEqual(today.brightnessText, "밝기 63%")
        XCTAssertEqual(today.moonAgeText, "달령 9.8일")
    }

    func testNextFullMoonIsFirstEvent() throws {
        let event = try XCTUnwrap(MoonFixtures.nextEvents.first)

        XCTAssertEqual(event.title, "다음 보름달")
        XCTAssertEqual(event.dateText, "7월 7일")
        XCTAssertEqual(event.countdownText, "5일 뒤")
    }

    func testVisibilityBeforeTransitShowsOnlyNextChange() throws {
        let summary = MoonFixtures.today.visibilitySummary(
            at: try date(hour: 18, minute: 30),
            calendar: utcCalendar
        )

        XCTAssertEqual(summary.status, "지금 떠 있어요")
        XCTAssertEqual(summary.nextEvent, "19:20에 가장 높이 떠요")
    }

    func testVisibilityAfterTransitShowsMoonset() throws {
        let summary = MoonFixtures.today.visibilitySummary(
            at: try date(hour: 20, minute: 0),
            calendar: utcCalendar
        )

        XCTAssertEqual(summary.status, "지금 떠 있어요")
        XCTAssertEqual(summary.nextEvent, "00:48에 져요")
    }

    func testVisibilityHandlesMoonsetAfterMidnight() throws {
        let beforeMoonset = MoonFixtures.today.visibilitySummary(
            at: try date(hour: 0, minute: 30),
            calendar: utcCalendar
        )
        let atMoonset = MoonFixtures.today.visibilitySummary(
            at: try date(hour: 0, minute: 48),
            calendar: utcCalendar
        )

        XCTAssertEqual(beforeMoonset.status, "지금 떠 있어요")
        XCTAssertEqual(beforeMoonset.nextEvent, "00:48에 져요")
        XCTAssertEqual(atMoonset.status, "지금은 떠 있지 않아요")
        XCTAssertEqual(atMoonset.nextEvent, "13:42에 떠요")
    }

    func testVisibilityAfterSameDayMoonsetShowsTomorrowRise() throws {
        let newMoon = MoonFixtures.day(for: 21)
        let summary = newMoon.visibilitySummary(
            at: try date(hour: 20, minute: 0),
            calendar: utcCalendar
        )

        XCTAssertEqual(summary.status, "오늘은 졌어요")
        XCTAssertEqual(summary.nextEvent, "내일 05:11에 떠요")
    }

    func testVisibilityGracefullyHandlesInvalidTime() throws {
        let invalidDay = MoonDay(
            day: 1,
            weekday: "수요일",
            phaseNameKo: "달",
            phaseNameEn: "Moon",
            illumination: 50,
            moonAge: 7,
            isWaxing: true,
            isMajorPhase: false,
            majorPhaseLabel: nil,
            moonrise: "알 수 없음",
            transit: "19:20",
            moonset: "00:48"
        )
        let summary = invalidDay.visibilitySummary(
            at: try date(hour: 18, minute: 30),
            calendar: utcCalendar
        )

        XCTAssertEqual(summary.status, "달 위치를 확인할 수 없어요")
        XCTAssertEqual(summary.nextEvent, "시간 정보를 다시 확인해 주세요")
    }

    func testCalendarIncludesMajorMoonPhases() {
        let labels = Set(MoonFixtures.calendarDays.compactMap(\.majorPhaseLabel))

        XCTAssertTrue(labels.contains("삭"))
        XCTAssertTrue(labels.contains("상현"))
        XCTAssertTrue(labels.contains("보름"))
        XCTAssertTrue(labels.contains("하현"))
    }

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(hour: Int, minute: Int) throws -> Date {
        var components = DateComponents()
        components.calendar = utcCalendar
        components.timeZone = utcCalendar.timeZone
        components.year = 2026
        components.month = 7
        components.day = 2
        components.hour = hour
        components.minute = minute

        return try XCTUnwrap(components.date)
    }
}
