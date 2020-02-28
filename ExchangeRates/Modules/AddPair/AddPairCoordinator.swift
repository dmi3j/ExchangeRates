//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation
import UIKit

protocol AddPairCoordinatorDelegate: class {
    func addPairCoordinatorDidCancel(_ coordinator: AddPairCoordinator)
    func addPairCoordinator(_ coordinator: AddPairCoordinator, didSelect pair: Pair)
}

final class AddPairCoordinator: Coordinator {
    weak var delegate: AddPairCoordinatorDelegate?
    
    private let existingPairs: [Pair]
    private let rootViewController: UIViewController
    private var navigationController = UINavigationController()
    private let storageService: Storage
    private var selectedSourceCurrency: Currency?
    
    init(existingPairs: [Pair], rootViewController: UIViewController, storage: Storage) {
        self.existingPairs = existingPairs
        self.rootViewController = rootViewController
        self.storageService = storage
    }
    
    func start() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let viewController = UIStoryboard(name: "AddPair", bundle: nil)
                .instantiateViewController(withIdentifier: "AddPairViewController") as? AddPairViewController else {
                    return
            }
            
            let viewModel = AddPairViewModelClass(storage: self.storageService,
                                                  mode: .source,
                                                  existingPairs: self.existingPairs)
            viewModel.coordinatorDeletage = self
            viewController.viewModel = viewModel
            self.navigationController = UINavigationController(rootViewController: viewController)
            self.navigationController.presentationController?.delegate = viewController
            self.rootViewController.present(self.navigationController, animated: true)
        }
    }
}

extension AddPairCoordinator: AddPairViewModelCoordinatorDelegate {
    
    func addPairViewModel(_ viewModel: AddPairViewModel, didSelect currency: Currency) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch viewModel.mode {
            case .source:
                self.selectedSourceCurrency = currency
                guard let viewController = UIStoryboard(name: "AddPair", bundle: nil)
                    .instantiateViewController(withIdentifier: "AddPairViewController") as? AddPairViewController else {
                        return
                }
                
                let viewModel = AddPairViewModelClass(storage: self.storageService,
                                                      mode: .target,
                                                      existingPairs: self.existingPairs,
                                                      sourceCurrency: currency)
                viewModel.coordinatorDeletage = self
                viewController.viewModel = viewModel
                self.navigationController.pushViewController(viewController, animated: true)
                break
            case .target:
                guard let sourceCurrency = self.selectedSourceCurrency else { return }
                self.rootViewController.dismiss(animated: true) {
                    self.delegate?.addPairCoordinator(self, didSelect: Pair(source: sourceCurrency, target: currency))
                }
            }
        }
    }
    
    func addPairViewModelDidCancel(_ viewModel: AddPairViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.rootViewController.dismiss(animated: true) {
                self.delegate?.addPairCoordinatorDidCancel(self)
            }
        }
    }
}



