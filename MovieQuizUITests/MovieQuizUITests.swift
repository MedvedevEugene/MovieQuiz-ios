//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Евгений Медведев on 13.03.2025.
//
import Foundation
import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    func testScreenCast() throws { }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    func testAlertDismissesAndCounterResets() {
        let app = XCUIApplication()
        app.launch()
        sleep(2)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        sleep(1)
        XCTAssertTrue(alert.exists, "Алерт не появился")

        let alertButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(alertButton.exists, "Кнопка 'Сыграть ещё раз' отсутствует")

        alertButton.tap()
        sleep(2)
        let alertDisappeared = expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: alert, handler: nil)
        wait(for: [alertDisappeared], timeout: 3)

        let indexLabel = app.staticTexts["Index"]
        sleep(1)
        let counterUpdated = expectation(for: NSPredicate(format: "label == '1/10'"), evaluatedWith: indexLabel, handler: nil)
        wait(for: [counterUpdated], timeout: 3)

        XCTAssertEqual(indexLabel.label, "1/10", "Счетчик не сбросился после перезапуска квиза")
    }

    
    func testAlertAppearsAtEndOfQuiz() {
        let app = XCUIApplication()
        app.launch()
        sleep(2)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        sleep(1)
        let alertExists = expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        wait(for: [alertExists], timeout: 3)
        
        XCTAssertTrue(alert.exists, "Алерт не появился")
        XCTAssertEqual(alert.label, "Этот раунд окончен!")

        let alertButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(alertButton.exists, "Кнопка 'Сыграть ещё раз' отсутствует")
    }

}
