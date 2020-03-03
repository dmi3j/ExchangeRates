//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import XCTest
@testable import ExRa

class AddPairViewModelTests: XCTestCase {

    func testCurrencyOrder() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(), mode: .source, existingPairs: [])
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.itemsCount, 3, "View model should return 4 items")
        XCTAssertEqual(viewModel.item(at: 0)?.currency, Currency(countryCode: "GBP"), "GBP should be first if exist")
        XCTAssertEqual(viewModel.item(at: 1)?.currency, Currency(countryCode: "EUR"), "EUR should be second if exist")
        XCTAssertEqual(viewModel.item(at: 4)?.currency, nil, "5th should not exist")
    }

    func testPrepareViewModelAllEnabledSource() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(), mode: .source, existingPairs: [])
               viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.item(at: 0)?.isEnabled, true, "Should be enabled")
        XCTAssertEqual(viewModel.item(at: 1)?.isEnabled, true, "Should be enabled")
        XCTAssertEqual(viewModel.item(at: 2)?.isEnabled, true, "Should be enabled")
    }

    func testPprepareViewModelMissingSourceCurrencyOnTarget() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(), mode: .target, existingPairs: [])
               viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.itemsCount, 0, "Should be no items")
    }

    func testPrepareViewModelAllEnabledSourceCurrencyIgnored() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .source,
                                              existingPairs: [],
                                              sourceCurrency: Currency(countryCode: "GBP"))
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.item(at: 0)?.isEnabled, true, "Should be enabled")
        XCTAssertEqual(viewModel.item(at: 1)?.isEnabled, true, "Should be enabled")
        XCTAssertEqual(viewModel.item(at: 2)?.isEnabled, true, "Should be enabled")
    }

    func testPrepareViewModelAllEnabledButSourceCurrency() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .target,
                                              existingPairs: [],
                                              sourceCurrency: Currency(countryCode: "GBP"))
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.item(at: 0)?.isEnabled, false, "Should NOT be enabled")
        XCTAssertEqual(viewModel.item(at: 1)?.isEnabled, true, "Should be enabled")
        XCTAssertEqual(viewModel.item(at: 2)?.isEnabled, true, "Should be enabled")
    }

    func testPrepareViewModelAllDisabled() {
        let existingPairs = [
            Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "ZAR")),
            Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "EUR"))
        ]
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .target,
                                              existingPairs: existingPairs,
                                              sourceCurrency: Currency(countryCode: "GBP"))
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.item(at: 0)?.isEnabled, false, "Should NOT be enabled")
        XCTAssertEqual(viewModel.item(at: 1)?.isEnabled, false, "Should be NOT enabled")
        XCTAssertEqual(viewModel.item(at: 2)?.isEnabled, false, "Should be NOT enabled")
    }

    func testPrepareViewModelLastEnabled() {
        let existingPairs = [
            Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "ZAR"))
        ]
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .target,
                                              existingPairs: existingPairs,
                                              sourceCurrency: Currency(countryCode: "GBP"))
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.item(at: 0)?.isEnabled, false, "Should NOT be enabled")
        XCTAssertEqual(viewModel.item(at: 1)?.isEnabled, true, "Should be enabled")
        XCTAssertEqual(viewModel.item(at: 2)?.isEnabled, false, "Should be NOT enabled")
    }


    func testPrepareViewModelOneDisabledBecauseOfExistingPairs() {
        let existingPairs = [
            Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "ZAR")),
            Pair(source: Currency(countryCode: "GBP"), target: Currency(countryCode: "EUR"))
        ]
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .source,
                                              existingPairs: existingPairs)
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.item(at: 0)?.isEnabled, false, "Should NOT be enabled")
        XCTAssertEqual(viewModel.item(at: 1)?.isEnabled, true, "Should be enabled")
        XCTAssertEqual(viewModel.item(at: 2)?.isEnabled, true, "Should be enabled")
    }

    func testSelectingNonExistingItem() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .source,
                                              existingPairs: [])
        viewModel.viewDidLoad()

        let coordinatorDelegate = TestCoordinatorDelegate01()
        viewModel.coordinatorDeletage = coordinatorDelegate

        //select value at index 4 with only 3 positions
        viewModel.selectItem(at: 4)
        let exp = expectation(description: "Did not add")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            exp.fulfill()
            XCTAssertFalse(coordinatorDelegate.didAddPair, "Should not possible to select non existing value")
        }

        waitForExpectations(timeout: 1.0) { (error) in
            if let error = error { XCTFail("Failed on timeout with error \(error)") }
        }
    }

    func testSelectingDisabledItem() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .target,
                                              existingPairs: [],
                                              sourceCurrency: Currency(countryCode: "GBP"))
        viewModel.viewDidLoad()

        let coordinatorDelegate = TestCoordinatorDelegate01()
        viewModel.coordinatorDeletage = coordinatorDelegate

        viewModel.selectItem(at: 0)
        let exp = expectation(description: "Did not add")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            exp.fulfill()
            XCTAssertFalse(coordinatorDelegate.didAddPair, "Should not possible to select disabled value")
        }

        waitForExpectations(timeout: 1.0) { (error) in
            if let error = error { XCTFail("Failed on timeout with error \(error)") }
        }
    }

    func testSelectingItem() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .source,
                                              existingPairs: [])
        viewModel.viewDidLoad()

        let coordinatorDelegate = TestCoordinatorDelegate01()
        viewModel.coordinatorDeletage = coordinatorDelegate

        viewModel.selectItem(at: 0)
        let exp = expectation(description: "Did add")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            exp.fulfill()
            XCTAssertTrue(coordinatorDelegate.didAddPair, "Should select item")
            XCTAssertEqual(coordinatorDelegate.selectedCurrency, Currency(countryCode: "GBP"), "GBP should be selected")
        }

        waitForExpectations(timeout: 3.0) { (error) in
            if let error = error { XCTFail("Failed on timeout with error \(error)") }
        }
    }

    func testCancelCallingCoordinatorDelegate() {
        let viewModel = AddPairViewModelClass(storage: TestStorage01(),
                                              mode: .source,
                                              existingPairs: [])
        viewModel.viewDidLoad()

        let coordinatorDelegate = TestCoordinatorDelegate01()
        viewModel.coordinatorDeletage = coordinatorDelegate

        viewModel.cancel()
        let exp = expectation(description: "Cancel called")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            exp.fulfill()
            XCTAssertTrue(coordinatorDelegate.didPressCancel, "Should call cancel")
        }

        waitForExpectations(timeout: 1.0) { (error) in
            if let error = error { XCTFail("Failed on timeout with error \(error)") }
        }
    }
}

private class TestStorage01: Storage {
    var availableCurrencies: [Currency] {
        return [
            Currency(countryCode: "ZAR"),
            Currency(countryCode: "EUR"),
            Currency(countryCode: "GBP")
        ]
    }

    func save(_ pairs: [Pair]) {}
    func load() -> [Pair] {
        return []
    }
}

private class TestRates01: Rates {
    func rates(for pairs: [Pair], completion: @escaping (Error?, [Pair : Float]) -> Void) {
        completion(nil, [Pair : Float]())
    }
}

private class TestCoordinatorDelegate01: AddPairViewModelCoordinatorDelegate {

    var didPressCancel = false
    var didAddPair = false
    var selectedCurrency: Currency? = nil

    func addPairViewModel(_ viewModel: AddPairViewModel, didSelect currency: Currency) {
        didAddPair = true
        selectedCurrency = currency
    }

    func addPairViewModelDidCancel(_ viewModel: AddPairViewModel) {
        didPressCancel = true
    }
}
