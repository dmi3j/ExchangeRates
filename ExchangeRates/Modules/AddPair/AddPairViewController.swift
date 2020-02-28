//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import UIKit

class AddPairViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: AddPairViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.viewDidLoad()
        
        if #available(iOS 13, *) {
            // no button needed as it dismissed with gestures
        } else {
            // add cancel button only on selecting source
            if navigationController?.viewControllers.first == self {
                let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
                navigationItem.leftBarButtonItem = closeButton
            }
        }
    }
    
    @objc
    func close(_ sender: UIBarButtonItem) {
        viewModel?.cancel()
    }
}

extension AddPairViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel?.cancel()
    }
}

extension AddPairViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.itemsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel?.item(at: indexPath.row) else { return UITableViewCell() }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyViewCell",
                                                       for: indexPath) as? CurrencyViewCell else {
                                                        return UITableViewCell()
        }
        cell.data = data
        return cell
    }
}

extension AddPairViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectItem(at: indexPath.row)
    }
}

extension AddPairViewController: AddPairViewDelegate {
    
    func reload() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }
    }
}
