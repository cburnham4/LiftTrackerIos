//
//  Lift_TrackerUITests.swift
//  Lift TrackerUITests
//
//  Created by Carl Burnham on 7/23/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import XCTest

class Lift_TrackerUITests: XCTestCase {

    let app = XCUIApplication()
    let outDir = URL(fileURLWithPath: "/tmp/asc-captures/lifttracker")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        setupSnapshot(app)
        app.launch()
        continueAsGuestIfNeeded()
    }

    override func tearDown() {
        super.tearDown()
    }

    func login() {
        let emailButton = app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        if emailButton.exists {
            emailButton.tap()
            let tablesQuery = app.tables
            let emailField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            emailField.tap()
            emailField.typeText("test@test.com")

            let passwordField = tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            passwordField.tap()
            passwordField.typeText("test1234")
            app.navigationBars["Sign in"].buttons["Sign in"].tap()
        }
    }

    func testExample() {
        snapshot("Home")
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Bench"]/*[[".cells.staticTexts[\"Bench\"]",".staticTexts[\"Bench\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        snapshot("AddSet")
        app.buttons["Past Lifts"].tap()
        snapshot("PastSets")
    }

    /// Captures screens for App Store marketing frames (writes PNGs under /tmp/asc-captures/lifttracker).
    func testCaptureAppStoreScreens() {
        let homeTitle = app.navigationBars["Lift Tracker"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 25), "Home should appear after launch/guest")

        save("01-home-exercises")

        let routines = app.buttons["Routines"].firstMatch
        if routines.waitForExistence(timeout: 5) {
            routines.tap()
            Thread.sleep(forTimeInterval: 1.0)
            save("02-home-routines")
        }

        let exercises = app.buttons["Exercises"].firstMatch
        if exercises.exists {
            exercises.tap()
            Thread.sleep(forTimeInterval: 0.8)
        }

        let preferred = ["Bench Press", "Deadlifts", "Squats", "Rows", "Front Squat"]
        var opened = false
        for name in preferred {
            let label = app.staticTexts[name].firstMatch
            if label.waitForExistence(timeout: 2) {
                label.tap()
                opened = true
                break
            }
        }
        if !opened {
            let cell = app.cells.firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Need at least one exercise")
            cell.tap()
        }
        Thread.sleep(forTimeInterval: 2.0)
        save("03-add-set")

        let past = app.buttons["Past Lifts"].firstMatch
        if past.waitForExistence(timeout: 6) {
            past.tap()
            Thread.sleep(forTimeInterval: 1.0)
            save("04-past-lifts")
        }

        let graph = app.buttons["Graph"].firstMatch
        if graph.waitForExistence(timeout: 6) {
            graph.tap()
            Thread.sleep(forTimeInterval: 1.2)
            save("05-graph")
        }

        // Back to home, open download flow
        if app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }

        let more = app.buttons["More"].firstMatch
        if more.waitForExistence(timeout: 4) {
            more.tap()
            Thread.sleep(forTimeInterval: 0.8)
            let download = app.sheets.buttons["Download Routines"].firstMatch
            let downloadAlt = app.buttons["Download Routines"].firstMatch
            if download.waitForExistence(timeout: 3) {
                download.tap()
            } else if downloadAlt.waitForExistence(timeout: 2) {
                downloadAlt.tap()
            }
            Thread.sleep(forTimeInterval: 2.0)
            save("06-download")
        }
    }

    private func continueAsGuestIfNeeded() {
        let guest = app.buttons["Continue as guest"]
        if guest.waitForExistence(timeout: 5) {
            guest.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
    }

    private func save(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let path = outDir.appendingPathComponent("\(name).png")
        do {
            try shot.pngRepresentation.write(to: path)
            print("📸 wrote \(path.path)")
        } catch {
            XCTFail("Failed to write screenshot \(name): \(error)")
        }
    }
}
