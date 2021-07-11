//
//  EmptyTimeLineViewController.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

class EmptyTimeLineViewController: EmptyDefaultViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString {
        let text = "Timeline"

        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    override func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString {
        let text = "See posts from people you follow"

        let paragragh = NSMutableParagraphStyle()
        paragragh.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragragh.alignment = NSTextAlignment.center

        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.paragraphStyle: paragragh
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    override func buttonTitle(forEmptyDataSet scrollView: UIScrollView,
                              for state: UIControl.State) -> NSAttributedString {
        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)
        ]

        return NSAttributedString(string: "Tap here to find friends", attributes: attributes)
    }

    override func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {

        if var image = UIImage(systemName: "house") {

            image = image.tint(UIColor.lightGray, blendMode: CGBlendMode.color)
            image = image.imageRotatedByDegrees(180, flip: false)
            return image
        }
        return UIImage()

    }

    override func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {
        presentView()
    }

    override func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        presentView()
    }

    func presentView() {
        let friendsViewController = ExploreView().formattedHostingController()
        friendsViewController.modalPresentationStyle = .popover
        present(friendsViewController, animated: true, completion: nil)
    }
}
