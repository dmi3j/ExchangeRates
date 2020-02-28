//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation
import UIKit

public protocol CoordinatorDelegate: class {
    
}

public protocol ViewDelegate: class {
    func show(message: String)
}

public protocol ViewModel: class {
    
}

extension ViewDelegate where Self: UIViewController {
    
    func show(message: String) {
        let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButtonAction)
        present(alertController, animated: true)
    }
}
