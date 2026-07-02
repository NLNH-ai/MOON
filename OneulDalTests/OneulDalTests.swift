import XCTest
@testable import OneulDal

final class OneulDalTests: XCTestCase {
    func testTodaySummaryMatchesPrototypeBrief() {
        let today = MoonFixtures.today

        XCTAssertEqual(today.phaseNameKo, "상현망간의 달")
        XCTAssertEqual(today.brightnessText, "밝기 63%")
        XCTAssertEqual(today.moonAgeText, "달령 9.8일")
        XCTAssertEqual(today.visibilityMessage, "지금 떠 있어요")
    }

    func testNextFullMoonIsFirstEvent() {
        let event = try XCTUnwrap(MoonFixtures.nextEvents.first)

        XCTAssertEqual(event.title, "다음 보름달")
        XCTAssertEqual(event.dateText, "7월 7일")
        XCTAssertEqual(event.countdownText, "D-5")
    }

    func testCalendarIncludesMajorMoonPhases() {
        let labels = Set(MoonFixtures.calendarDays.compactMap(\.majorPhaseLabel))

        XCTAssertTrue(labels.contains("삭"))
        XCTAssertTrue(labels.contains("상현"))
        XCTAssertTrue(labels.contains("보름"))
        XCTAssertTrue(labels.contains("하현"))
    }
}
