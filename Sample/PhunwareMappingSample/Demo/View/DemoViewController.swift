//
//  DemoViewController.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareFoundation

class DemoViewController: UITableViewController {
    
    var viewModel: DemoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard viewModel != nil else {
            assertionFailure("`viewModel` is required for `\(Self.self)` to work.")
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.handleViewDidAppear()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.handleSelection(at: indexPath)
    }
}

// MARK: - StoryboardInitializable
extension DemoViewController: StoryboardInitializable {
    
    static var storyboardName: String {
        return "Demo"
    }
}
