//
//  CommentViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift
import UIKit

class CommentViewModel: ObservableObject {
    @Published var activity: Activity?
    @Published var comment = ""

    init(post: Post? = nil, activity: Activity? = nil) {
        if activity != nil {
            self.activity = activity
        } else {
            self.activity = Activity(type: .comment, from: User.current, to: post?.user)
            self.activity?.post = post
        }
    }

    // MARK: Intents

    func save() {
        if !comment.isEmpty {
            activity?.comment = comment
            activity?.save { _ in }
        }
    }
}
