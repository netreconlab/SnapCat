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
    var postedAt: Date?
    var location: ParseGeoPoint?

    init(image: ParseFile) {
        user = User.current
        self.image = image
        ACL = try? ParseACL.defaultACL()
    }
}

extension Post: Identifiable {

    var id: String { // swiftlint:disable:this identifier_name
        guard let objectId = self.objectId else {
            return UUID().uuidString
        }
        return objectId
    }
}
