//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import XCTest
@testable import ExRa

class PairListViewModelTests: XCTestCase {

    func testLoading() {
        let viewModel = PairListViewModelClass(storage: TestStorage(), rates: TestRates())
        viewModel.viewDidLoad()
        XCTAssertNil(viewModel.item(at: 3), "There should not be 4th item")
        XCTAssertEqual(viewModel.item(at: 0)?.pair.source.countryCode, "GBP", "Source currency should be GBP")
        XCTAssertEqual(viewModel.item(at: 0)?.pair.target.countryCode, "USD", "Target currency should be USD")
    }

    func testRemove() {
        let viewModel = PairListViewModelClass(storage: TestStorage(), rates: TestRates())
        viewModel.viewDidLoad()
        XCTAssertEqual(viewModel.itemsCount, 3, "View model should return 3 items")
        viewModel.remove(at: 3)
        XCTAssertEqual(viewModel.itemsCount, 3, "View model should return 3 items")
        viewModel.remove(at: 2)
        XCTAssertEqual(viewModel.itemsCount, 2, "View model should return 2 items")
    }

    func testAdd() {
        let viewModel = PairListViewModelClass(storage: TestStorage(), rates: TestRates())
        viewModel.viewDidLoad()
        let existingPair = Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "USD"))
        let neewPair = Pair(source: Currency(countryCode: "EUR"), target: Currency(countryCode: "GBP"))
        XCTAssertEqual(viewModel.itemsCount, 3, "View model should return 3 items")
        viewModel.add(existingPair)
        XCTAssertEqual(viewModel.itemsCount, 3, "View model should return 3 items")
        viewModel.add(neewPair)
        XCTAssertEqual(viewModel.itemsCount, 4, "View model should return 4 items")
    }

    func testCallCoordinatorDelegateAddPair() {
        let viewModel = PairListViewModelClass(storage: TestStorage(), rates: TestRates())
        let coordinatorDelegate = TestCoordinatorDelegate()
        viewModel.coordinatorDeletage = coordinatorDelegate
        viewModel.addPair()
        let exp = expectation(description: "Did call")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            exp.fulfill()
            XCTAssertTrue(coordinatorDelegate.didCall, "Should call")
        }
        waitForExpectations(timeout: 1.0) { (error) in
            if let error = error { XCTFail("Failed on timeout with error \(error)") }
        }
    }

    func testNotifyObservers() {
        let viewModel = PairListViewModelClass(storage: TestStorage(), rates: TestRates())
        let neewPair = Pair(source: Currency(countryCode: "EUR"), target: Currency(countryCode: "GBP"))
        let observer = TestRateObserver()
        viewModel.addObserver(observer)
        viewModel.add(neewPair)
        let exp = expectation(description: "Did call")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            exp.fulfill()
            XCTAssertTrue(observer.didCall, "Should be called")
        }
        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error { XCTFail("Failed on timeout with error \(error)") }
        }
    }

    func testNotNotifyRemovedObservers() {
        let viewModel = PairListViewModelClass(storage: TestStorage(), rates: TestRates())
        let neewPair = Pair(source: Currency(countryCode: "EUR"), target: Currency(countryCode: "GBP"))
        let observer = TestRateObserver()
        viewModel.addObserver(observer)
        viewModel.removeObserver(observer)
        viewModel.add(neewPair)
        let exp = expectation(description: "Did call")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            exp.fulfill()
            XCTAssertFalse(observer.didCall, "Should NOT be called")
        }
        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error { XCTFail("Failed on timeout with error \(error)") }
        }
    }

    func testObserverRequest() {
        let viewModel = PairListViewModelClass(storage: TestStorage(), rates: TestRates())
        viewModel.viewDidLoad()
        let pair = Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "USD"))
        XCTAssertEqual(viewModel.rate(for: pair), Float(1.333), "Rate should be 1.333")
    }
}

private class TestStorage: Storage {
    var availableCurrencies: [Currency] {
        return [
            Currency(countryCode: "ZAR"),
            Currency(countryCode: "PHP"),
            Currency(countryCode: "EUR"),
            Currency(countryCode: "GBP")
        ]
    }

    func save(_ pairs: [Pair]) {}
    func load() -> [Pair] {
        return [
            Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "USD")),
            Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "EUR")),
            Pair(source: Currency(countryCode: "USD"), target: Currency(countryCode: "GBP"))
        ]
    }
}

private class TestRates: Rates {
    func rates(for pairs: [Pair], completion: @escaping (Error?, [Pair : Float]) -> Void) {
        let pair = Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "USD"))
        let rate: Float = 1.333
        completion(nil, [pair : rate])
    }
}


private class TestCoordinatorDelegate: PairListViewModelCoordinatorDelegate {
    var didCall = false
    func pairListViewModel(_ viewModel: PairListViewModel, addPairTo existingPairs: [Pair]) {
        didCall = true
    }
}

private class TestRateObserver: RateObserver {
    var didCall = false

    func rateChanged() {
        didCall = true
    }
}
