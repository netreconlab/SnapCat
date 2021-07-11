//
//  Logger+extension.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let category = "SnapCat"
    static let user = Logger(subsystem: subsystem, category: "\(category).user")
    static let installation = Logger(subsystem: subsystem, category: "\(category).installation")
    static let activity = Logger(subsystem: subsystem, category: "\(category).activity")
    static let post = Logger(subsystem: subsystem, category: "\(category).post")
    static let onboarding = Logger(subsystem: subsystem, category: "\(category).onboarding")
    static let main = Logger(subsystem: subsystem, category: "\(category).main")
    static let home = Logger(subsystem: subsystem, category: "\(category).home")
    static let explore = Logger(subsystem: subsystem, category: "\(category).explore")
    static let profile = Logger(subsystem: subsystem, category: "\(category).profile")
    static let notification = Logger(subsystem: subsystem, category: "\(category).notification")
    static let utility = Logger(subsystem: subsystem, category: "\(category).utility")
    static let settings = Logger(subsystem: subsystem, category: "\(category).settings")
}
