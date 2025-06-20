//
//  UIViewController+App.swift
//  PhunwareMappingSample
//
//  Created by Troy Stump on 8/25/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var topmostPresentedViewController: UIViewController {
        var viewController = self
        
        while let presentedVC = viewController.presentedViewController {
            viewController = presentedVC
        }
        
        return viewController
    }
}
