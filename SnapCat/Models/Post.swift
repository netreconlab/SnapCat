//
//  Post.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

struct Post: ParseObject {

    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var user: User?
    var image: ParseFile?
    var thumbnail: ParseFile?
    var location: ParseGeoPoint?
    var caption: String?

    func merge(with object: Self) throws -> Self {
        var updated = try mergeParse(with: object)
        if updated.shouldRestoreKey(\.user,
                                     original: object) {
            updated.user = object.user
        }
        if updated.shouldRestoreKey(\.image,
                                     original: object) {
            updated.image = object.image
        }
        if updated.shouldRestoreKey(\.thumbnail,
                                     original: object) {
            updated.thumbnail = object.thumbnail
        }
        if updated.shouldRestoreKey(\.location,
                                     original: object) {
            updated.location = object.location
        }
        if updated.shouldRestoreKey(\.caption,
                                     original: object) {
            updated.caption = object.caption
        }
        return updated
    }
}

extension Post {
    init(image: ParseFile?) {
        user = User.current
        self.image = image
    }
}
