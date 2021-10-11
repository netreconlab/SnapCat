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

    var user: User?
    var image: ParseFile?
    var thumbnail: ParseFile?
    var location: ParseGeoPoint?
    var caption: String?

    init(image: ParseFile? = nil) {
        user = User.current
        self.image = image
        ACL = try? ParseACL.defaultACL()
    }
}

extension Post {

    var emptyObject: Self {
        var object = Self()
        object.objectId = objectId
        object.createdAt = createdAt
        return object
    }
}
