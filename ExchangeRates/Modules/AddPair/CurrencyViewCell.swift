//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import UIKit

class CurrencyViewCell: UITableViewCell {

    @IBOutlet private weak var currencyCode: UILabel!
    @IBOutlet private weak var currencyName: UILabel!
    @IBOutlet private weak var currencyIcon: UIImageView!

    var data: CurrencyModel? {
        didSet {
            guard let data = data else { return }

            currencyCode.text = data.currency.countryCode
            currencyName.text = data.currency.currencyName

            if let image = UIImage(named: data.currency.countryCode) {
                currencyIcon.image = image
            } else {
                currencyIcon.image = UIImage(named: "unknown")
            }

            if data.isEnabled {
                contentView.alpha = 1
            } else {
                contentView.alpha = 0.5
            }
        }
    }
}
