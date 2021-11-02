//
//  User.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

struct User: ParseUser, ParseObjectMutable {

    // Mandatory properties
    var authData: [String: [String: String]?]?
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    // Custom properties
    var name: String?
    var profileImage: ParseFile?
    var profileThumbnail: ParseFile?
    var bio: String?
    var link: URL?
}
