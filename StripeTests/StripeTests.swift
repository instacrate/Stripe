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
    
    func testNormalAccount() {
        do {
            let token = try Stripe.shared.createToken()
            let customer = try Stripe.shared.createNormalAccount(email: "test_user_\(NSUUID().uuidString)@test.test", source: token.id)
        } catch {
            print(error)
            XCTFail("failed generating stripe token")
        }
    }
    
    func testManagedAccount() {
        do {
            let token = try Stripe.shared.createToken()
            let customer = try Stripe.shared.createManagedAccount(email: "test_user_\(NSUUID().uuidString)@test.test", source: token.id)
        } catch {
            print(error)
            XCTFail("failed generating stripe token")
        }
    }
    
    func testAssociateTokenWithUser() {
        do {
            let token = try Stripe.shared.createToken()
            let customer = try Stripe.shared.createNormalAccount(email: "test_user_\(NSUUID().uuidString)@test.test", source: token.id)

            let token2 = try Stripe.shared.createToken()
            let test = try Stripe.shared.associate(source: token2.id, withStripe: customer.id)
        } catch {
            print(error)
            XCTFail("failed generating stripe token")
        }
    }

    func testCreatePlan() {
        do {
            let plan = try Stripe.shared.createPlan(with: 10.2, name: "test_plan_\(NSUUID().uuidString)", interval: .month)
        } catch {
            print(error)
            XCTFail("failed generating stripe token")
        }
    }

    func testSubscribeUserToPlan() {
        do {
            let plan = try Stripe.shared.createPlan(with: 10.2, name: "test_plan_\(NSUUID().uuidString)", interval: .month)
            let token = try Stripe.shared.createToken()
            let customer = try Stripe.shared.createNormalAccount(email: "test_user_\(NSUUID().uuidString)@test.test", source: token.id)

            let subscription = try Stripe.shared.subscribe(user: customer.id, to: plan.id, oneTime: false)
        } catch {
            print(error)
            XCTFail("failed generating stripe token")
        }
    }

    func testGetPaymentMethods() {
        do {
            let token = try Stripe.shared.createToken()
            let customer = try Stripe.shared.createNormalAccount(email: "test_user_\(NSUUID().uuidString)@test.test", source: token.id)

            let sources = try Stripe.shared.paymentInformation(for: customer.id)
        } catch {
            print(error)
            XCTFail("failed generating stripe token")
        }
    }

    func testDeletePaymentMethod() {
        do {
            let token = try Stripe.shared.createToken()
            let customer = try Stripe.shared.createNormalAccount(email: "test_user_\(NSUUID().uuidString)@test.test", source: token.id)

            let token2 = try Stripe.shared.createToken()
            let _ = try Stripe.shared.associate(source: token2.id, withStripe: customer.id)


        } catch {
            print(error)
            XCTFail("failed deleting payment method")
        }
    }

    func testGetDisputes() {
        do {
            let disputes = try Stripe.shared.disputes()
        } catch {
            print(error)
            XCTFail("failed getting disputes")
        }
    }
}
