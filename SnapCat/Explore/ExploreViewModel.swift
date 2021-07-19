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
import UIKit

@dynamicMemberLookup
class ExploreViewModel: ObservableObject {

    @Published var users = [User]() {
        willSet {
            newValue.forEach { object in
                // Fetch images
                if profileImages.count == Constants.numberOfImagesToDownload {
                    return
                }
                guard profileImages[object.id] == nil else {
                    return
                }
                Utility.fetchImage(object.profileImage) { image in
                    if let image = image {
                        self.profileImages[object.id] = image
                    }
                }
            }
        }
    }

    /// Contains all fetched images.
    @Published var profileImages = [String: UIImage]()

    subscript(dynamicMember member: String) -> [User] {
        return users
    }

    init(users: [User]? = nil) {
        guard let users = users else {
            queryUsersNotFollowing()
            return
        }
        self.users = users
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
                var objectIds = foundUsers.compactMap { $0.toUser?.id }
                objectIds.append(currentUserObjectId)
                let query = User.query(notContainedIn(key: ParseKey.objectId, array: objectIds))

                query.find { result in
                    switch result {

                    case .success(let users):
                        self.users = users
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
                self.users = self.users.filter({ $0.objectId != activity.toUser?.objectId })
            case .failure(let error):
                Logger.explore.error("Couldn't save follow: \(error)")
            }
        }
    }
}
