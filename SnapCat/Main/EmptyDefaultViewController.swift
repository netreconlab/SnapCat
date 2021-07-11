//
//  EmptyDefaultViewController.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

class EmptyDefaultViewController: UITableViewController {

    let defaultImage = UIImage(systemName: "house")

    deinit {
        self.tableView.emptyDataSetSource = nil
        self.tableView.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
    }
}

// UITableViewDataSource, UITableViewDelegate
extension EmptyDefaultViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// DZNEmptyDataSet Delegates. More info about how to use here: https://github.com/dzenbot/DZNEmptyDataSet
extension EmptyDefaultViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "Empty Data"

        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "Empty data"

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

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)
        ]

        return NSAttributedString(string: "Tap here", attributes: attributes)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if var image = self.defaultImage {
            image = image.tint(UIColor.lightGray, blendMode: CGBlendMode.color)
            image = image.imageRotatedByDegrees(180, flip: false)
            return image
        }
        return UIImage()
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }
}

extension EmptyDefaultViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {

    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {

    }
}
