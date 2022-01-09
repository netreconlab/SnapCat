//
//  PostStatus.swift
//  SnapCat
//
//  Created by Corey Baker on 1/8/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

class PostStatus: ObservableObject {
    @Published var isShowing: Bool

    init(isShowing: Bool = false) {
        self.isShowing = isShowing
    }
}
