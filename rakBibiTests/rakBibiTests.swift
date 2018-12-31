//
//  rakBibiTests.swift
//  rakBibiTests
//
//  Created by Nadav Vanunu on 26/12/2018.
//  Copyright © 2018 Nadav Vanunu. All rights reserved.
//

import XCTest
@testable import rakBibi

class rakBibiTests: XCTestCase {

    var vcFiltersTable: ViewController!
    
    override func setUp() {
        super.setUp()
        
        UserDefaults().removePersistentDomain(forName: "group.rakBibi")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ViewController = storyboard.instantiateViewController(withIdentifier: "filterTable") as! ViewController
        vcFiltersTable = vc
        _ = vcFiltersTable.view // To call viewDidLoad
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UserDefaults().removePersistentDomain(forName: "group.rakBibi")

    }

    func testAddNewFilter_addEmpty() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let before = vcFiltersTable.filters.count
        let newFilterStr = ""
        vcFiltersTable.addNewFilter(newFilter: newFilterStr)
        XCTAssertNotEqual(before + 1, vcFiltersTable.filters.count, "adding empty filter should not raise the filters count")
    }
    
    func testAddNewFilter_addSingle() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var before = vcFiltersTable.filters.count
        let newFilterStr = "abc"
        vcFiltersTable.addNewFilter(newFilter: newFilterStr)
        XCTAssertEqual(before + 1, vcFiltersTable.filters.count, "filter count should raise by 1")
        
        before = vcFiltersTable.filters.count
        vcFiltersTable.addNewFilter(newFilter: newFilterStr)
        XCTAssertNotEqual(before + 1, vcFiltersTable.filters.count, "adding same filter twice should not raise the filters count")
    }
    
    func testAddNewFilter_addMulty() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var before = vcFiltersTable.filters.count
        let newFilterStr = "efg,hij,k123"
        vcFiltersTable.addNewFilter(newFilter: newFilterStr)
        XCTAssertEqual(before + 3, vcFiltersTable.filters.count, "filter count should raise by 1")
        
        before = vcFiltersTable.filters.count
        vcFiltersTable.addNewFilter(newFilter: newFilterStr)
        XCTAssertNotEqual(before + 3, vcFiltersTable.filters.count, "adding same filter twice should not raise the filters count")
        
        before = vcFiltersTable.filters.count
        vcFiltersTable.addNewFilter(newFilter: "efg,hij_1,k123_1")
        XCTAssertEqual(before + 2, vcFiltersTable.filters.count, "adding same filter twice should not raise the filters count")
    }
    
    func testAddNewFilter_addMultySpecial() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let before = vcFiltersTable.filters.count
        let newFilterStr = "efg,,k123"
        vcFiltersTable.addNewFilter(newFilter: newFilterStr)
        XCTAssertEqual(before + 2, vcFiltersTable.filters.count, "filter count should raise by 2s")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
