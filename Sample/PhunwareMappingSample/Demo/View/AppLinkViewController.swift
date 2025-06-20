//
//  AppLinkViewController.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 9/21/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareFoundation

class AppLinkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!
    
    var viewModel: AppLinkViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.appLinkSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.appLinkSections[section].links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let applink = appLink(at: indexPath) else { return UITableViewCell() }
        
        var content = UIListContentConfiguration.subtitleCell()
        content.text = applink.actionContent
        content.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        content.secondaryText = applink.supportsExternal ? "Internal & External" : "Internal"
        content.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .regular)
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.appLinkSections[section].name
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let appLink = appLink(at: indexPath) else { return }
        viewModel.handleAppLinkSelection(appLink)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let appLink = appLink(at: indexPath),
              appLink.supportsExternal else { return nil }
        
        return .init(actionProvider:  { _ in
            let copyAction = UIAction(title: "Copy External Link") { _ in
                let encodedAppLink = appLink.actionContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? appLink.actionContent
                
                UIPasteboard.general.string = "phunwaremapping://\(encodedAppLink)"
            }
            
            return UIMenu(title: "", children: [
                copyAction
            ])
        })
    }
    
    @IBAction func didTapCloseButton() {
        viewModel.handleCloseButtonTap()
    }
    
    private func appLink(at indexPath: IndexPath) -> AppLink? {
        viewModel.appLinkSections[indexPath.section].links[indexPath.row]
    }
}

// MARK: - StoryboardInitializable
extension AppLinkViewController: StoryboardInitializable {
    static var storyboardName: String {
        return "Demo"
    }
}
