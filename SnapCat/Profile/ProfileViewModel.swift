//
//  ProfileViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift
import SwiftUI
import UIKit

@MainActor
class ProfileViewModel: ObservableObject { // swiftlint:disable:this type_body_length
    var explorerView: ExploreView?
    @Published var user: User
    @Published var error: SnapCatError?
    var username: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
            objectWillChange.send()
        }
    }
    var email: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
            objectWillChange.send()
        }
    }
    var name: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
            objectWillChange.send()
        }
    }
    var bio: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
            objectWillChange.send()
        }
    }
    var link: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
            objectWillChange.send()
        }
    }
    @Published var isHasChanges = false
    @Published var currentUserFollowers = [User]()
    @Published var currentUserFollowings = [User]()
    @Published var isShowingHeading = true
    private var settingProfilePicForFirstTime = true
    var profilePicture = UIImage(systemName: "person.circle") {
        willSet {
            if !isSettingForFirstTime {
                guard var currentUser = User.current?.emptyObject,
                      currentUser.hasSameObjectId(as: user),
                      let image = newValue,
                      let compressed = image.compressTo(3) else {
                    return
                }
                let newProfilePicture = ParseFile(name: "profile.jpeg", data: compressed)
                currentUser.profileImage = newProfilePicture
                let immutableCurrentUser = currentUser
                Task {
                    do {
                        let user = try await immutableCurrentUser.save()
                        self.user = user
                        do {
                            let fetchedUser = try await user.fetch()
                            do {
                                _ = try await fetchedUser.profileImage?.fetch()
                                Logger.profile.info("Saved profile pic to cache")
                            } catch {
                                Logger.profile.error("Error fetching pic \(error.localizedDescription)")
                            }
                        } catch {
                            Logger.profile.error("Error fetching profile pic from cloud: \(error.localizedDescription)")
                        }
                    } catch {
                        guard let parseError = error as? ParseError else {
                            return
                        }
                        Logger.profile.error("Error saving profile pic \(error.localizedDescription)")
                        self.error = SnapCatError(parseError: parseError)
                    }
                }
                objectWillChange.send()
            }
        }
    }
    private var isSettingForFirstTime = true

    init(user: User?, isShowingHeading: Bool) {
        guard let currentUser = User.current else {
            Logger.profile.error("User should be logged in to perfom action.")
            self.user = User()
            return
        }
        if let user = user {
            self.user = user
        } else {
            self.user = currentUser
        }
        self.isShowingHeading = isShowingHeading
        if let username = self.user.username {
            self.username = username
        }
        if let email = self.user.email {
            self.email = email
        }
        if let name = self.user.name {
            self.name = name
        }
        if let bio = self.user.bio {
            self.bio = bio
        }
        if let link = self.user.link {
            self.link = link.absoluteString
        }
        self.isSettingForFirstTime = false
        Task {
            let image = await Utility.fetchImage(self.user.profileImage)
            self.isSettingForFirstTime = true
            self.profilePicture = image
            self.isSettingForFirstTime = false
        }
        Task {
            do {
                let activities = try await Self.queryFollowers().find()
                self.currentUserFollowers = activities.compactMap { $0.fromUser }
            } catch {
                Logger.explore.error("Failed to query current followers: \(error.localizedDescription)")
            }
        }
        Task {
            do {
                let activities = try await Self.queryFollowings().find()
                self.currentUserFollowings = activities.compactMap { $0.toUser }
            } catch {
                Logger.explore.error("Failed to query current followings: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Intents
    func followUser() async {
        do {
            let newActivity = try Activity(type: .follow, from: User.current, to: user)
                .setupForFollowing()
            do {
                _ = try await newActivity.save()
            } catch {
                Logger.profile.error("Couldn't save follow: \(error.localizedDescription)")
            }
        } catch {
            Logger.profile.error("Can't create follow activity \(error.localizedDescription)")
        }
    }

    func unfollowUser() async {
        do {
            guard let currentUser = User.current else {
                return
            }
            let query = try Activity.query(ActivityKey.fromUser == currentUser,
                                           ActivityKey.toUser == user,
                                           ActivityKey.type == Activity.ActionType.follow)
            do {
                let activity = try await query.first()
                do {
                    try await activity.delete()
                } catch {
                    Logger.profile.error("Couldn't unfollow user \(error.localizedDescription)")
                }

            } catch {
                Logger.profile.error("Couldn't find activity to unfollow \(error.localizedDescription)")
            }
        } catch {
            Logger.profile.error("Couldn't unwrap during unfollow \(error.localizedDescription)")
        }
    }

    // MARK: Helpers
    func isCurrentFollower() -> Bool {
        currentUserFollowers.first(where: { $0.hasSameObjectId(as: user) }) != nil
    }

    func isCurrentFollowing() -> Bool {
        currentUserFollowings.first(where: { $0.hasSameObjectId(as: user) }) != nil
    }

    class func getUsersFromFollowers(_ activities: [Activity]) -> [User] {
        activities.compactMap { $0.fromUser }
    }

    class func getUsersFromFollowings(_ activities: [Activity]) -> [User] {
        activities.compactMap { $0.toUser }
    }

    // MARK: - Intents

    func saveUpdates() async throws -> User {
        guard var currentUser = User.current?.emptyObject else {
            let snapCatError = SnapCatError(message: "Trying to save when user isn't logged in")
            Logger.profile.error("\(snapCatError.message)")
            throw snapCatError
        }
        if !currentUser.hasSameObjectId(as: user) {
            let snapCatError = SnapCatError(message: "Trying to save when this isn't the logged in user")
            Logger.profile.error("\(snapCatError.message)")
            throw snapCatError
        }
        var changesNeedToBeSaved = false
        if username != user.username && !username.isEmpty {
            currentUser.username = username
            changesNeedToBeSaved = true
        }
        if email != user.email && !email.isEmpty {
            currentUser.email = email
            changesNeedToBeSaved = true
        }
        if name != user.name && !name.isEmpty {
            currentUser.name = name
            changesNeedToBeSaved = true
        }
        if bio != user.bio && !bio.isEmpty {
            currentUser.bio = bio
            changesNeedToBeSaved = true
        }
        if URL(string: link) != user.link && !link.isEmpty {
            currentUser.link = URL(string: link)
            changesNeedToBeSaved = true
        }
        if changesNeedToBeSaved {
            let user = try await currentUser.save()
            Logger.profile.info("User saved updates")
            self.user = user
            self.isHasChanges = false
            return user
        } else {
            let snapCatError = SnapCatError(message: "No new changes to save")
            Logger.profile.debug("\(snapCatError.message)")
            throw snapCatError
        }
    }

    func resetPassword() async throws {
        guard let email = User.current?.email else {
            let snapCatError = SnapCatError(message: "Need to save a valid email address before reseting password")
            self.error = snapCatError
            throw snapCatError
        }
        do {
            return try await User.passwordReset(email: email)
        } catch {
            guard let parseError = error as? ParseError else {
                return
            }
            let snapCatError = SnapCatError(parseError: parseError)
            self.error = snapCatError
            throw snapCatError
        }
    }

    // MARK: - Queries
    class func queryUserTimeLine(_ user: User?=nil) -> Query<Post> {
        let userPointer: Pointer<User>!
        if let otherUser = user {
            guard let pointer = try? otherUser.toPointer() else {
                return Post.query().limit(0)
            }
            userPointer = pointer
        } else {
            guard let pointer = try? User.current?.toPointer() else {
                return Post.query().limit(0)
            }
            userPointer = pointer
        }
        return Post.query(PostKey.user == userPointer)
            .order([.descending(ParseKey.createdAt)])
    }

    class func queryFollowers(_ user: User?=nil) -> Query<Activity> {

        var query = Activity.query().limit(0)
        if let currentUser = User.current {
            if let user = user {
                query = Activity.query(ActivityKey.toUser == user.objectId,
                                       ActivityKey.fromUser != user.objectId,
                                       ActivityKey.type == Activity.ActionType.follow.rawValue)
                    .order([.descending(ParseKey.updatedAt)])
            } else {
                query = Activity.query(ActivityKey.toUser == currentUser.objectId,
                                       ActivityKey.fromUser != currentUser.objectId,
                                       ActivityKey.type == Activity.ActionType.follow.rawValue)
                    .order([.descending(ParseKey.updatedAt)])
            }
        }
        return query
    }

    class func queryFollowings(_ user: User?=nil) -> Query<Activity> {

        if let user = user {
            return Activity.query(ActivityKey.fromUser == user.objectId,
                                  ActivityKey.toUser != user.objectId,
                                  ActivityKey.type == Activity.ActionType.follow.rawValue)
                .order([.descending(ParseKey.updatedAt)])
        } else {
            guard let currentUser = User.current else {
                Logger.main.error("Utility.queryActivitiesForFollowings(), user not logged in.")
                return Activity.query().limit(0)
            }
            return Activity.query(ActivityKey.fromUser == currentUser.objectId,
                                  ActivityKey.toUser != currentUser.objectId,
                                  ActivityKey.type == Activity.ActionType.follow.rawValue)
                .order([.descending(ParseKey.updatedAt)])
        }
    }
}
