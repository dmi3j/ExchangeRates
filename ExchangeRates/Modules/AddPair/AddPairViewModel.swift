//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation

enum AddPairMode {
    case source
    case target
}

protocol AddPairViewModelCoordinatorDelegate: CoordinatorDelegate {
    func addPairViewModel(_ viewModel: AddPairViewModel, didSelect currency: Currency)
    func addPairViewModelDidCancel(_ viewModel: AddPairViewModel)
}

protocol AddPairViewDelegate: ViewDelegate {
    func reload()
}

protocol AddPairViewModel: ViewModel {
    var coordinatorDeletage: AddPairViewModelCoordinatorDelegate? { get set }
    var viewDelegate: AddPairViewDelegate? { get set }
    
    var mode: AddPairMode { get }
    var itemsCount: Int { get }
    func item(at index: Int) -> CurrencyModel?
    func selectItem(at index: Int)
    func viewDidLoad()
    func cancel()
}

final class AddPairViewModelClass: AddPairViewModel {
    
    let mode: AddPairMode
    
    private let storageService: Storage
    private let existingPairs: [Pair]
    private let sourceCurrency: Currency?
    
    private let priorityCurrencies = [
        Currency(countryCode: "GBP"),
        Currency(countryCode: "EUR"),
        Currency(countryCode: "USD")
    ]
    
    private var items = [CurrencyModel]()
    private var availableCurrencies = [Currency]()
    
    init(storage: Storage, mode: AddPairMode, existingPairs: [Pair], sourceCurrency: Currency? = nil ) {
        self.storageService = storage
        self.mode = mode
        self.existingPairs = existingPairs
        self.sourceCurrency = sourceCurrency
    }
    
    // MARK: - AddPairViewModel
    weak var coordinatorDeletage: AddPairViewModelCoordinatorDelegate?
    weak var viewDelegate: AddPairViewDelegate?
    
    var itemsCount: Int {
        return items.count
    }
    
    func item(at index: Int) -> CurrencyModel? {
        return items.indices.contains(index) ? items[index] : nil
    }
    
    func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        let selectedItem = items[index]
        guard selectedItem.isEnabled else { return }
                
        coordinatorDeletage?.addPairViewModel(self, didSelect: selectedItem.currency)
    }
    
    func viewDidLoad() {
        prepareViewModel()
    }
    
    func cancel() {
        coordinatorDeletage?.addPairViewModelDidCancel(self)
    }
}

private extension AddPairViewModelClass {
    
    func prepareViewModel() {
        items = []
        availableCurrencies = []
        
        var storedCurrencies = storageService.availableCurrencies
        
        /// put seleceted currencies on top of the list; if exist
        priorityCurrencies.reversed().forEach( { priorityCurrency in
            if storedCurrencies.contains(where: { $0.countryCode == priorityCurrency.countryCode }) {
                storedCurrencies.removeAll(where: { $0.countryCode == priorityCurrency.countryCode })
                storedCurrencies.insert(priorityCurrency, at: 0)
            }
        })
        
        availableCurrencies = storedCurrencies
        
        switch mode {
        case .source:
            /// verify that for any currency a pair is possible considering already existing pairs
            availableCurrencies.forEach { (availableCurrency) in
                var bookedCurrencies = existingPairs
                    .filter({ $0.source == availableCurrency })
                    .map({ $0.target })
                bookedCurrencies.append(availableCurrency)
                let isEnabled = bookedCurrencies.count < availableCurrencies.count
                items.append(CurrencyModel(currency: availableCurrency, isEnabled: isEnabled ))
            }
            
        case .target:
            guard let selectedSourceCurrency = sourceCurrency else { return }
            
            let bookedCurrencies = existingPairs
                .filter({ $0.source == selectedSourceCurrency })
                .map({ $0.target })
            
            availableCurrencies.forEach { (availableCurrency) in
                var isEnabled = !bookedCurrencies.contains(availableCurrency)
                if selectedSourceCurrency == availableCurrency {
                    isEnabled = false
                }
                items.append(CurrencyModel(currency: availableCurrency, isEnabled: isEnabled ))
            }
        }
        
        viewDelegate?.reload()
    }
}
