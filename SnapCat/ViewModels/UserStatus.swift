//
//  UserStatus.swift
//  SnapCat
//
//  Created by Corey Baker on 1/8/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

@MainActor
class UserStatus: ObservableObject {
    @Published var isLoggedOut = true

    init() {
        check()
    }

    init(isLoggedOut: Bool) {
        self.isLoggedOut = isLoggedOut
    }

    func check() {
        if User.current != nil {
            isLoggedOut = false
        } else {
            isLoggedOut = true
        }
    }
}
