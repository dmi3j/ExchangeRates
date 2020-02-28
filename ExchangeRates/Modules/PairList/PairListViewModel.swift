//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation

protocol PairListViewModelCoordinatorDelegate: CoordinatorDelegate {
    func pairListViewModel(_ viewModel: PairListViewModel, addPairTo existingPairs: [Pair])
}

protocol PairListViewDelegate: ViewDelegate {
    func reload()
}

protocol PairListViewModel: ViewModel, RatePublisher {
    var coordinatorDeletage: PairListViewModelCoordinatorDelegate? { get set }
    var viewDelegate: PairListViewDelegate? { get set }

    var itemsCount: Int { get }
    func item(at index: Int) -> PairModel?
    func remove(at index: Int)
    func addPair()
    func add(_ pair: Pair)
    func viewDidLoad()
}

final class PairListViewModelClass: PairListViewModel {

    private let ratesCheckInterval = TimeInterval(1.0)
    private var timer: Timer?
    private var isCheckInProgress = false

    private var pairs = [Pair]()
    private var items = [PairModel]()
    private var rates = [Pair: Float]()
    private var observers = [WeakObserver]()

    private let storageService: Storage
    private let ratesService: Rates

    init(storage: Storage, rates: Rates) {
        self.storageService = storage
        self.ratesService = rates
    }

    // MARK: - PairListViewModel
    weak var coordinatorDeletage: PairListViewModelCoordinatorDelegate?
    weak var viewDelegate: PairListViewDelegate?

    var itemsCount: Int {
        return items.count
    }

    func item(at index: Int) -> PairModel? {
        return items.indices.contains(index) ? items[index] : nil
    }

    func remove(at index: Int) {
        guard pairs.indices.contains(index) else { return }
        stopTimer()
        pairs.remove(at: index)
        storageService.save(pairs)
        items.remove(at: index)
        prepareViewModel()
    }

    func addPair() {
        coordinatorDeletage?.pairListViewModel(self, addPairTo: pairs)
    }

    func add(_ pair: Pair) {
        guard pairs.contains(pair) == false else { return }
        stopTimer()
        pairs.append(pair)
        storageService.save(pairs)
        prepareViewModel()
    }

    func viewDidLoad() {
        pairs = storageService.load()
        prepareViewModel()
    }
}

private extension PairListViewModelClass {

    func prepareViewModel() {
        stopTimer()
        reloadRates()
    }

    func reloadRates() {
        ratesService.rates(for: pairs) { (error, result) in
            self.rates = result

            var updatedRates = [PairModel]()

            self.pairs.forEach { (pair) in

                let item = PairModel(pair: pair,
                                     sourceCurrencyUnit: "1 \(pair.source.countryCode)",
                    sourceCurrencyName: "\(pair.source.countryCode)",
                    rate: result[pair],
                    targetCurrencyName: "\(pair.target.currencyName) · \(pair.target.countryCode)")
                updatedRates.append(item)

            }

            self.items = updatedRates
            self.viewDelegate?.reload()
            self.reStartTimer()
        }
    }

    func reStartTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: ratesCheckInterval,
                                     target: self,
                                     selector: #selector(checkRates),
                                     userInfo: nil,
                                     repeats: true)
        timer?.tolerance = 0.5
    }

    func stopTimer() {
        timer?.invalidate()
        isCheckInProgress = false
    }

    @objc
    func checkRates() {
        guard isCheckInProgress == false else { return }
        isCheckInProgress = true

        ratesService.rates(for: pairs) { (error, result) in
            self.rates = result

            self.isCheckInProgress = false
            for observer in self.observers {
                observer.object?.rateChanged()
            }
        }
    }
}

extension PairListViewModelClass: RatePublisher {

    func addObserver(_ observer: RateObserver) {
        observers.append(WeakObserver(object: observer))
    }

    func removeObserver(_ observer: RateObserver) {
        var filteredObservers = [WeakObserver]()
        observers.forEach { (weakObserver) in
            if let objet = weakObserver.object {
                if objet !== observer { filteredObservers.append(weakObserver) }
            }
        }
        observers = filteredObservers
    }

    func rate(for pair: Pair) -> Float? {
        return rates[pair]
    }
}

