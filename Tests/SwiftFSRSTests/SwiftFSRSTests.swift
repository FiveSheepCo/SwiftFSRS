//
//  FSRSTests.swift
//  FSRSTests
//
//  Created by Ben on 11/08/2023.
//

import XCTest

@testable import SwiftFSRS

final class FSRSTests: XCTestCase {
    func testExample() throws {
        var f = FSRS()
        let card = Card()

        XCTAssertEqual(card.status, .new)

        f.p.w = [
            1.0171, 1.8296, 4.4145, 10.9355, 5.0965, 1.3322, 1.017, 0.0, 1.6243, 0.1369, 1.0321,
            2.1866, 0.0661, 0.336, 1.7766, 0.1693, 2.9244
        ]
        
        // Tue Nov 29 2022 05:30:00 UTC+0000
        let now = Date(timeIntervalSince1970: 1669699800)
        var schedulingCards = f.repeat(card: card, now: now)
        
        print(schedulingCards)
        
        let ratings: [Rating] = [
            .good, .good, .good, .good, .good, .good, .again,
            .again, .good, .good, .good, .good, .good
        ]
        var ivlHistory: [Double] = []
        var statusHistory: [Status] = []
        
        for rating in ratings {
            if let s = schedulingCards[rating] {
                let card = s.card
                ivlHistory.append(card.scheduledDays)
                
                let revlog = s.reviewLog
                statusHistory.append(revlog.status)
                let now = card.due
                schedulingCards = f.repeat(card: card, now: now)
                
                log(schedulingInfo: schedulingCards)
            }
        }
        
        print(ivlHistory)
        print(statusHistory)
        
        XCTAssertEqual(ivlHistory, [0, 4, 15, 49, 143, 379, 0, 0, 15, 37, 85, 184, 376])
        XCTAssertEqual(statusHistory, [
            .new, .learning, .review, .review, .review, .review, .review,
            .relearning, .relearning, .review, .review, .review, .review
        ])
    }

    func log(schedulingInfo: [Rating: SchedulingInfo]) {
        var data = [String: String]()
        for key in schedulingInfo.keys {
            if let info = schedulingInfo[key] {
                data[String(describing: key)] = String(describing: info)
            }
        }
        print("\(data)")
    }
}
