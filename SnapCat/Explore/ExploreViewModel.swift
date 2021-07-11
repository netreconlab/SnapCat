//
//  ExploreViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift

@dynamicMemberLookup
class ExploreViewModel: ObservableObject {

    @Published var notFollowing = [User]()

    subscript(dynamicMember member: String) -> [User] {
        return notFollowing
    }

    init() {
        queryUsersNotFollowing()
    }

    // MARK: Intents
    func queryUsersNotFollowing() {
        guard let currentUserObjectId = User.current?.objectId else {
            Logger.explore.error("Couldn't get own objectId")
            return
        }
        ProfileViewModel.queryFollowings().find { result in
            switch result {

            case .success(let foundUsers):
                var objectIds = foundUsers.compactMap { $0.objectId }
                objectIds.append(currentUserObjectId)
                let query = User.query(notContainedIn(key: ParseKey.objectId, array: objectIds))

                query.find { result in
                    switch result {

                    case .success(let users):
                        self.notFollowing = users
                    case .failure(let error):
                        Logger.explore.error("Couldn't query users: \(error)")
                    }
                }
            case .failure(let error):
                Logger.explore.error("Couldn't find followings: \(error)")
            }
        }
    }

    func followUser(_ user: User) {
        let newActivity = Activity(type: .follow, from: User.current, to: user)
        newActivity.save { result in
            switch result {

            case .success(let activity):
                self.notFollowing = self.notFollowing.filter({ $0.objectId != activity.toUser?.objectId })
            case .failure(let error):
                Logger.explore.error("Couldn't save follow: \(error)")
            }
        }
    }
}
