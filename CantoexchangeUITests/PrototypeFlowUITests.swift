import XCTest

final class PrototypeFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func button(_ app: XCUIApplication, labelStartingWith text: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", text)).firstMatch
    }

    func testWalkThroughPrototypeFlow() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["CantoExchange"].waitForExistence(timeout: 20))
        capture("01-login")

        button(app, labelStartingWith: "Send Verification Code").tap()

        XCTAssertTrue(app.staticTexts["Language & fluency"].waitForExistence(timeout: 10))
        button(app, labelStartingWith: "English").tap()
        button(app, labelStartingWith: "Yes, I am fluent").tap()
        capture("02-onboarding-mentor")

        button(app, labelStartingWith: "Continue to App").tap()

        XCTAssertTrue(app.staticTexts["Auntie Mary"].firstMatch.waitForExistence(timeout: 10))
        capture("03-mentor-dashboard")

        button(app, labelStartingWith: "Accept").firstMatch.tap()
        capture("04-mentor-after-accept")

        app.tabBars.buttons["Sessions"].tap()
        XCTAssertTrue(app.staticTexts["Upcoming"].waitForExistence(timeout: 10))
        capture("05-sessions-upcoming")

        button(app, labelStartingWith: "Past").firstMatch.tap()
        capture("06-sessions-past")

        app.tabBars.buttons["Mentor"].tap()
        button(app, labelStartingWith: "Learner").firstMatch.tap()
        capture("07-learner-dashboard")

        app.swipeUp()
        button(app, labelStartingWith: "Schedule Offline Meeting").firstMatch.tap()
        XCTAssertTrue(
            app.navigationBars["Schedule Offline Meeting"].waitForExistence(timeout: 10)
        )
        capture("08-scheduler")

        app.swipeUp()
        button(app, labelStartingWith: "Online Voice Call").tap()
        capture("09-scheduler-voice")

        button(app, labelStartingWith: "Confirm Meeting").tap()
        sleep(2)
        capture("10-scheduler-confirmed")
    }
}
