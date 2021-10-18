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

@MainActor @dynamicMemberLookup
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
    var users = [User]() {
        willSet {
            newValue.forEach { object in
                // Fetch images
                if profileImages.count == Constants.numberOfImagesToDownload {
                    return
                }
                guard profileImages[object.id] == nil else {
                    return
                }
                Task {
                    if let image = await Utility.fetchImage(object.profileImage) {
                        self.profileImages[object.id] = image
                    }
                }
            }
            objectWillChange.send()
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
            Task {
                await queryUsersNotFollowing()
            }
        }
        Task {
            do {
                let activities = try await ProfileViewModel.queryFollowers().find()
                self.currentUserFollowers = activities.compactMap { $0.fromUser }
            } catch {
                Logger.explore.error("Failed to query current followers: \(error.localizedDescription)")
            }
        }
        Task {
            do {
                let activities = try await ProfileViewModel.queryFollowings().find()
                self.currentUserFollowings = activities.compactMap { $0.toUser }
            } catch {
                Logger.explore.error("Failed to query current followings: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Intents
    func followUser(_ user: User) {
        do {
            let newActivity = try Activity(type: .follow, from: User.current, to: user)
                .setupForFollowing()
            self.users = self.users.filter({ $0.objectId != user.objectId })
            Task {
                do {
                    _ = try await newActivity.save()
                } catch {
                    Logger.explore.error("Couldn't save follow: \(error.localizedDescription)")
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
        self.followingsViewModel?.results.removeAll(where: { $0.hasSameObjectId(as: activity) })
        self.updateFollowings()
        Task {
            do {
                try await activity.delete()
            } catch {
                Logger.explore.error("Couldn't delete activity \(error.localizedDescription)")
            }
        }
    }

    // MARK: Helpers
    func queryUsersNotFollowing() async {
        guard let currentUserObjectId = User.current?.objectId else {
            Logger.explore.error("Couldn't get own objectId")
            return
        }
        Task {
            do {
                let foundUsers = try await ProfileViewModel.queryFollowings().find()
                var objectIds = foundUsers.compactMap { $0.toUser?.id }
                objectIds.append(currentUserObjectId)
                let query = User.query(notContainedIn(key: ParseKey.objectId, array: objectIds))
                do {
                    self.users = try await query.find()
                } catch {
                    Logger.explore.error("Couldn't query users: \(error.localizedDescription)")
                }
            } catch {
                Logger.explore.error("Couldn't find followings: \(error.localizedDescription)")
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
