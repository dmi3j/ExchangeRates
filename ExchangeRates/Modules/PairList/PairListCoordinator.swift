//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation
import UIKit

class PairListCoordinator: Coordinator {

    private let window: UIWindow
    private var childCoordinator: Coordinator?
    private var navigationController = UINavigationController()

    private let storage: Storage = StorageService()
    private let rates: Rates = RatesService()

    private lazy var pairListViewModel: PairListViewModel = {
        let viewModel = PairListViewModelClass(storage: storage, rates: rates)
        viewModel.coordinatorDeletage = self
        return viewModel
    }()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            guard let viewController = UIStoryboard(name: "PairList", bundle: nil)
                .instantiateViewController(withIdentifier: "PairListViewController") as? PairListViewController else {
                    return
            }

            viewController.viewModel = self.pairListViewModel

            self.navigationController = UINavigationController(rootViewController: viewController)
            self.navigationController.navigationBar.isHidden = true
            self.window.rootViewController = self.navigationController
            self.window.makeKeyAndVisible()
        }
    }
}

extension PairListCoordinator: PairListViewModelCoordinatorDelegate {

    func pairListViewModel(_ viewModel: PairListViewModel, addPairTo existingPairs: [Pair]) {
        let coordinator = AddPairCoordinator(existingPairs: existingPairs,
                                              rootViewController: navigationController, storage: storage)
        childCoordinator = coordinator
        coordinator.delegate = self
        coordinator.start()
    }
}

extension PairListCoordinator: AddPairCoordinatorDelegate {

    func addPairCoordinatorDidCancel(_ coordinator: AddPairCoordinator) {
        childCoordinator = nil
    }

    func addPairCoordinator(_ coordinator: AddPairCoordinator, didSelect pair: Pair) {
        pairListViewModel.add(pair)
        childCoordinator = nil
    }
}
