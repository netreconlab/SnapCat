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
    var isSettingForFirstTime = true
    var isShowingFollowers: Bool?
    var followersViewModel: QueryViewModel<Activity>? {
        willSet {
            if !isSettingForFirstTime {
                guard let followers = newValue else {
                    return
                }
                users = followers.results.compactMap { $0.fromUser }
            }
        }
    }
    var followingsViewModel: QueryViewModel<Activity>? {
        willSet {
            if !isSettingForFirstTime {
                guard let followings = newValue else {
                    return
                }
                users = followings.results.compactMap { $0.toUser }
            }
        }
    }
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

    @Published var currentUserFollowers = [User]()
    @Published var currentUserFollowings = [User]()

    /// Contains all fetched images.
    @Published var profileImages = [String: UIImage]()

    subscript(dynamicMember member: String) -> [User] {
        return users
    }

    init(isShowingFollowers: Bool? = nil,
         followersViewModel: QueryViewModel<Activity>? = nil,
         followingsViewModel: QueryViewModel<Activity>? = nil) {
        if let isShowingFollowers = isShowingFollowers {
            guard let followersViewModel = followersViewModel,
                  let followingsViewModel = followingsViewModel else {
                return
            }
            self.followersViewModel = followersViewModel
            self.followingsViewModel = followingsViewModel
            self.isShowingFollowers = isShowingFollowers
            if isShowingFollowers {
                updateFollowers()
            } else {
                updateFollowings()
            }
            self.isSettingForFirstTime = false
        } else {
            queryUsersNotFollowing()
        }
        ProfileViewModel.queryFollowers().find { result in
            switch result {

            case .success(let activities):
                self.currentUserFollowers = activities.compactMap { $0.fromUser }
            case .failure(let error):
                Logger.explore.error("Failed to query current followers: \(error)")
            }
        }
        ProfileViewModel.queryFollowings().find { result in
            switch result {

            case .success(let activities):
                self.currentUserFollowings = activities.compactMap { $0.toUser }
            case .failure(let error):
                Logger.explore.error("Failed to query current followings: \(error)")
            }
        }
    }

    // MARK: Intents
    func followUser(_ user: User) {
        do {
            let newActivity = try Activity(type: .follow, from: User.current, to: user)
                .setupForFollowing()
            newActivity.save { result in
                switch result {

                case .success(let activity):
                    self.users = self.users.filter({ $0.objectId != activity.toUser?.objectId })
                case .failure(let error):
                    Logger.explore.error("Couldn't save follow: \(error)")
                }
            }
        } catch {
            Logger.explore.error("Can't create follow activity \(error.localizedDescription)")
        }
    }

    func unfollowUser(_ toUser: User) {
        guard let currentUser = User.current,
              let activity = followingsViewModel?.results.first(where: { activity in
                  guard let activityToUser = activity.toUser,
                        let activityFromUser = activity.fromUser,
                        let activityType = activity.type,
                        activityToUser.hasSameObjectId(as: toUser),
                        activityFromUser.hasSameObjectId(as: currentUser),
                        activityType == Activity.ActionType.follow else {
                      return false
                  }
                  return true
              }) else {
            return
        }

        activity.delete { result in
            if case .failure(let error) = result {
                Logger.explore.error("Couldn't delete activity \(error)")
            } else {
                self.followingsViewModel?.results.removeAll(where: { $0.hasSameObjectId(as: activity) })
                self.updateFollowings()
            }
        }
    }

    // MARK: Helpers
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

    func isCurrentFollower(_ user: User?) -> Bool {
        guard let user = user else { return false }
        return currentUserFollowers.first(where: { $0.hasSameObjectId(as: user) }) != nil
    }

    func isCurrentFollowing(_ user: User?) -> Bool {
        guard let user = user else { return false }
        return currentUserFollowings.first(where: { $0.hasSameObjectId(as: user) }) != nil
    }

    func updateFollowers() {
        guard let followersViewModel = followersViewModel else {
            return
        }
        self.users = followersViewModel.results.compactMap { $0.fromUser }
    }
    func updateFollowings() {
        guard let followingsViewModel = followingsViewModel else {
            return
        }
        self.users = followingsViewModel.results.compactMap { $0.toUser }
    }
}
