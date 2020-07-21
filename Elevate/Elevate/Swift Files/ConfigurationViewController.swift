/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation details of a modal view that presents the PoseNet algorithm parameters
 to the user.
*/

import UIKit

protocol ConfigurationViewControllerDelegate: AnyObject {
    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateConfiguration: PoseBuilderConfiguration)

    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateAlgorithm: Algorithm)
}

class ConfigurationViewController: UIViewController {
    
    weak var delegate: ConfigurationViewControllerDelegate?

    var configuration: PoseBuilderConfiguration! {
        didSet {
            delegate?.configurationViewController(self, didUpdateConfiguration: configuration)
        }
    }

    var algorithm: Algorithm = .multiple {
        didSet {
            delegate?.configurationViewController(self, didUpdateAlgorithm: algorithm)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
