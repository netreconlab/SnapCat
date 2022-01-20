//
//  User.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

struct User: ParseUser {

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
    var originalData: Data?

    // Custom properties
    var name: String?
    var profileImage: ParseFile?
    var profileThumbnail: ParseFile?
    var bio: String?
    var link: URL?

    func merge(with object: Self) throws -> Self {
        var updated = try mergeParse(with: object)
        if updated.shouldRestoreKey(\.name,
                                     original: object) {
            updated.name = object.name
        }
        if updated.shouldRestoreKey(\.profileImage,
                                     original: object) {
            updated.profileImage = object.profileImage
        }
        if updated.shouldRestoreKey(\.profileThumbnail,
                                     original: object) {
            updated.profileThumbnail = object.profileThumbnail
        }
        if updated.shouldRestoreKey(\.bio,
                                     original: object) {
            updated.bio = object.bio
        }
        if updated.shouldRestoreKey(\.link,
                                     original: object) {
            updated.link = object.link
        }
        return updated
    }
}
