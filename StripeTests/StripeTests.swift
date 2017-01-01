//
//  StripeTests.swift
//  StripeTests
//
//  Created by Hakon Hanesand on 12/23/16.
//
//

import XCTest
@testable import Stripe

class StripeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        do {
            let token = try Stripe.shared.createToken()
            let customer = try Stripe.shared.createNormalAccount(email: "\(NSUUID().uuidString)@test.test", source: token.id)
        } catch {
            print(error)
            XCTFail("failed generating stripe token")
        }
    }

}
