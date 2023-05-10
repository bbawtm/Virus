//
//  VirusTests.swift
//  VirusTests
//
//  Created by Vadim Popov on 07.05.2023.
//

import XCTest
@testable import Virus

final class VirusTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFirstStep() async throws {
        let col = 100
        
        for factor in [1, 3, 5, 8] {
            let engine: VirusEngine? = .init(col*col, factor, 0.1)
            var stepsCount = 0
            
            engine!.connectUI(columnsCount: col) {
                stepsCount += 1
                if stepsCount == 1 {
                    XCTAssertEqual(engine?.getDesk().sick, 2 * (1 + factor))
                }
            }
            
            engine!.addInfected((col / 4) * 100 + (col / 4))
            engine!.addInfected((3 * col / 4) * 100 + (3 * col / 4))
            
            while engine?.isRunning() ?? false {
                sleep(1)
            }
            XCTAssertEqual(engine?.getDesk().sick, col*col)
        }
    }

}
