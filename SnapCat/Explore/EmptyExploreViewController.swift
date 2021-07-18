//
//  EmptyExploreViewController.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

class EmptyExploreViewController: EmptyDefaultViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString {
        let text = "Explore"

        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    override func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString {
        let text = "Follow, meet, and engage with people"

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

        return NSAttributedString(string: "", attributes: attributes)
    }

    override func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {

        if var image = UIImage(systemName: "magnifyingglass.circle") {

            image = image.tint(UIColor.lightGray, blendMode: CGBlendMode.color)
            image = image.imageRotatedByDegrees(180, flip: false)
            return image
        }
        return UIImage()

    }

    override func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {

    }

    override func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {

    }
}
