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
    var originalData: Data?

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

    enum LikeState: String, Codable {
        case like
        case unlike
        case error
    }

    func merge(with object: Self) throws -> Self {
        var updated = try mergeParse(with: object)
        if updated.shouldRestoreKey(\.fromUser,
                                     original: object) {
            updated.fromUser = object.fromUser
        }
        if updated.shouldRestoreKey(\.toUser,
                                     original: object) {
            updated.toUser = object.toUser
        }
        if updated.shouldRestoreKey(\.type,
                                     original: object) {
            updated.type = object.type
        }
        if updated.shouldRestoreKey(\.comment,
                                     original: object) {
            updated.comment = object.comment
        }
        if updated.shouldRestoreKey(\.post,
                                     original: object) {
            updated.post = object.post
        }
        if updated.shouldRestoreKey(\.activity,
                                     original: object) {
            updated.activity = object.activity
        }
        return updated
    }

    func setupForFollowing() throws -> Activity {
        var activity = self
        if activity.type == .follow {
            guard let followUser = activity.toUser else {
                throw SnapCatError(message: "missing \(ActivityKey.toUser)")
            }
            activity.ACL?.setWriteAccess(user: followUser, value: true)
            activity.ACL?.setReadAccess(user: followUser, value: true)
        } else {
            throw SnapCatError(message: "Can't setup for following for type: \"\(String(describing: type))\"")
        }
        return activity
    }

    static func like(post: Post) -> Self {
        var activity = Activity(type: .like, from: User.current, to: post.user)
        activity.post = post
        return activity
    }
}

extension Activity {

    init(type: ActionType, from fromUser: User?, to toUser: User?) {
        self.type = type
        self.fromUser = fromUser
        self.toUser = toUser
    }
}
