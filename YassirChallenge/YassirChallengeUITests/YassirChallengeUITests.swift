//
//  YassirChallengeUITests.swift
//  YassirChallengeUITests
//
//  Created by Omar Ali on 21/8/25.
//

import XCTest

final class YassirChallengeUITests: XCTestCase {
  func testFilteringAndNavigating() throws {
    let app = XCUIApplication()
    app.launch()

    let firstCharacterWithoutFilters = "Rick Sanchez"
    let firstAliveCharacter = "Rick Sanchez"
    let firstDeadCharacter = "Adjudicator Rick"
    let firstUnknownCharacter = "Abradolf Lincler"
    
    checkCharacterExsistance(firstCharacterWithoutFilters, app: app)

    tap("Unknown", app: app)
    checkCharacterExsistance(firstUnknownCharacter, app: app)
    
    tap("Dead", app: app)
    checkCharacterExsistance(firstDeadCharacter, app: app)
    
    tap("Alive", app: app)
    checkCharacterExsistance(firstAliveCharacter, app: app)
    
    tap(firstAliveCharacter, app: app)
    checkCharacterExsistance(firstAliveCharacter, app: app)
  }
  
  func testInfiniteScrolling() throws {
      let app = XCUIApplication()
      app.launch()

      let laterCharacter = "Aqua Morty"

      let laterCharacterElement = app.staticTexts[laterCharacter]
      XCTAssertFalse(laterCharacterElement.isHittable, "\(laterCharacter) should not be visible before scrolling")

      let table = app.tables.firstMatch
      var found = false
      for _ in 0..<5 {
          table.swipeUp()
          if laterCharacterElement.isHittable {
              found = true
              break
          }
      }

      XCTAssertTrue(found, "Infinite scrolling did not load \(laterCharacter)")
  }
  
  private func tap(_ text: String, app: XCUIApplication) {
    let text = app.staticTexts[text]
    text.tap()
  }
  
  private func checkCharacterExsistance(_ characterName: String, app: XCUIApplication) {
    let cell = app.staticTexts[characterName]
    XCTAssertTrue(cell.waitForExistence(timeout: 5), "Could not find character \(characterName)")
  }
}
