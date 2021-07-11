//
//  EmptyExploreView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import UIKit

struct EmptyExploreView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        let view = EmptyExploreViewController()
        let viewController = UINavigationController(rootViewController: view)
        viewController.navigationBar.isHidden = true
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}

struct EmptyExploreView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyExploreView()
    }
}
