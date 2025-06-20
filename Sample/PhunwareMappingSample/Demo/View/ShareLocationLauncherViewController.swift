//
//  ShareLocationLauncherViewController.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 10/4/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import UIKit

class ShareLocationLauncherViewController: UIViewController {
    private let viewModel: ShareLocationLauncherViewModel
    
    init(viewModel: ShareLocationLauncherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        let buttonAction = UIAction(title: "Share My Location") { _ in
            self.viewModel.handleShareLocationButtonTap()
        }
        
        let button = UIButton(type: .system, primaryAction: buttonAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
