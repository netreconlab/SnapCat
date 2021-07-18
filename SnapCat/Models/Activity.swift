//
//  Activity.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

struct Activity: ParseObject {

    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    var fromUser: User?
    var toUser: User?
    var type: ActionType?
    var comment: String?
    var post: Post?
    var activity: Pointer<Activity>?

    enum ActionType: String, Codable {
        case like
        case follow
        case comment
    }

    init(type: ActionType, from fromUser: User?, to toUser: User?) {
        self.type = type
        self.fromUser = fromUser
        self.toUser = toUser
        ACL = try? ParseACL.defaultACL()
    }

    static func like(post: Post) -> Self {
        var activity = Activity(type: .like, from: User.current, to: post.user)
        activity.post = post
        return activity
    }
}

extension Activity: Identifiable {

    var id: String { // swiftlint:disable:this identifier_name
        guard let objectId = self.objectId else {
            return UUID().uuidString
        }
        return objectId
    }
}
