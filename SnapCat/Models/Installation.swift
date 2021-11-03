//
//  Installation.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

struct Installation: ParseInstallation, ParseObjectMutable {
    var deviceType: String?

    var installationId: String?

    var deviceToken: String?

    var badge: Int?

    var timeZone: String?

    var channels: [String]?

    var appName: String?

    var appIdentifier: String?

    var appVersion: String?

    var parseVersion: String?

    var localeIdentifier: String?

    var objectId: String?

    var createdAt: Date?

    var updatedAt: Date?

    var ACL: ParseACL?
}
