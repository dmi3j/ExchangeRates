//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import UIKit

class PairListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addPairButton: UIButton!
    @IBOutlet private weak var emptyView: UIView!

    var viewModel: PairListViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addPairButton.layer.cornerRadius = addPairButton.frame.size.width / 2
        viewModel?.viewDidLoad()
    }

    @IBAction func addFirstPair(_ sender: UIButton) {
        viewModel?.addPair()
    }

    lazy var addPairGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addPair(_:)))
        return gestureRecognizer
    }()

    @objc
    func addPair(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            viewModel?.addPair()
        }
    }
}

extension PairListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.itemsCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel?.item(at: indexPath.row) else { return UITableViewCell() }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PairViewCell",
                                                       for: indexPath) as? PairViewCell else {
                                                        return UITableViewCell()
        }
        cell.ratePublisher = viewModel
        cell.data = data
        return cell        
    }
}

extension PairListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let viewModel = viewModel, viewModel.itemsCount > 0 else { return CGFloat.zero }
        return 60.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let nib = UINib(nibName: "AddCurrencyHeaderView", bundle: nil)
        let objects = nib.instantiate(withOwner: nil, options: nil)
        guard let headerView = objects.first as? AddCurrencyHeaderView else { return nil }
        headerView.addGestureRecognizer(addPairGestureRecognizer)
        return headerView
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /// workaround to clean up observers
            if let cell = tableView.cellForRow(at: indexPath) as? PairViewCell {
                cell.ratePublisher?.removeObserver(cell)
            }
            viewModel?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension PairListViewController: PairListViewDelegate {

    func reload() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.emptyView.isHidden = (self.viewModel?.itemsCount ?? 0) > 0
            self.tableView.reloadData()
        }
    }
}
