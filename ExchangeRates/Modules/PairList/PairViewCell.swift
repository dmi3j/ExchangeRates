//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import UIKit

class PairViewCell: UITableViewCell {

    @IBOutlet private weak var sourceCurrencyUnit: UILabel!
    @IBOutlet private weak var sourceCurrencyName: UILabel!
    @IBOutlet private weak var rateValue: UILabel!
    @IBOutlet private weak var rateValueB: UILabel!
    @IBOutlet private weak var targetCurrencyName: UILabel!

    weak var ratePublisher: RatePublisher? {
        didSet {
            ratePublisher?.addObserver(self)
        }
    }

    var data: PairModel? {
        didSet {
            guard let data = data else { return }

            sourceCurrencyUnit.text = data.sourceCurrencyUnit
            sourceCurrencyName.text = data.sourceCurrencyName
            targetCurrencyName.text = data.targetCurrencyName
            updateRates(with: data.rate)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        ratePublisher?.removeObserver(self)
    }

    deinit {
        ratePublisher?.removeObserver(self)
    }
}

extension PairViewCell: RateObserver {

    func rateChanged() {
        guard let data = data else { return }

        updateRates(with: ratePublisher?.rate(for: data.pair))
    }
}

private extension PairViewCell {

    func updateRates(with value: Float?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let value = value {
                self.rateValue.text =  String(format: "%.2f", value)
                self.rateValueB.text = String(String(format: "%.4f", value).suffix(2))
            } else {
                self.rateValue.text = "-.--"
                self.rateValueB.text = "--"
            }
        }
    }
}
