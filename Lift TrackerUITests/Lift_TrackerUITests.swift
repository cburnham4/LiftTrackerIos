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
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func login() {
        let emailButton = app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        if (emailButton.exists) {
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
    
}
