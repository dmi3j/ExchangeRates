//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import UIKit

class AddCurrencyHeaderView: UIView {

    @IBOutlet private weak var plusButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        plusButton.layer.cornerRadius = plusButton.frame.size.width / 2
    }
}
