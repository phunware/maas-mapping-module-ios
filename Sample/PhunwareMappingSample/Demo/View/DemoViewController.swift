//
//  DemoViewController.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 1/25/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import UIKit
import Combine
import PhunwareFoundation

class DemoViewController: UITableViewController {
    
    @IBOutlet private var infoLabel: UILabel!

    private var bindings = Set<AnyCancellable>()

    var viewModel: DemoViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard viewModel != nil else {
            assertionFailure("`viewModel` is required for `\(Self.self)` to work.")
            return
        }

        configureBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.handleViewDidAppear()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.demos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        
        guard let demo = demo(at: indexPath) else { return cell }
        
        var content = UIListContentConfiguration.cell()
        content.text = demo.label
        content.image = UIImage(systemName: demo.iconName)
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.handleSelection(at: indexPath)
    }
}

// MARK: - Private (Bindings)
private extension DemoViewController {
    
    func configureBindings() {
        viewModel.$info
            .sink { [infoLabel] in
                infoLabel?.text = $0
                infoLabel?.sizeToFit()
            }
            .store(in: &bindings)
    }
    
    func demo(at indexPath: IndexPath) -> Demo? {
        guard viewModel.demos.indices.contains(indexPath.row) else { return nil }
        
        return viewModel.demos[indexPath.row]
    }
}

// MARK: - Private (Actions)
private extension DemoViewController {
    
    @IBAction func didTapAppLinkButton() {
        viewModel.handleAppLinkButtonTap()
    }
}

// MARK: - StoryboardInitializable
extension DemoViewController: StoryboardInitializable {
    
    static var storyboardName: String {
        return "Demo"
    }
}
