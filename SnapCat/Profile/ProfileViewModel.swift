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

// swiftlint:disable:next type_body_length
class ProfileViewModel: ObservableObject {
    var explorerView: ExploreView?
    @Published var user: User
    @Published var error: SnapCatError?
    @Published var username: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
        }
    }
    @Published var email: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
        }
    }
    @Published var name: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
        }
    }
    @Published var bio: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
        }
    }
    @Published var link: String = "" {
        willSet {
            if !isSettingForFirstTime {
                isHasChanges = true
            }
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
                currentUser.save { result in
                    switch result {

                    case .success(let user):
                        self.user = user
                        user.fetch { result in
                            switch result {

                            case .success(let fetchedUser):

                                fetchedUser.profileImage?.fetch { result in
                                    switch result {

                                    case .success:
                                        Logger.profile.info("Saved profile pic to cache")
                                    case .failure(let error):
                                        Logger.profile.error("Error fetching pic \(error)")
                                    }
                                }

                            case .failure(let error):
                                Logger.profile.error("Error fetching profile pic from cloud: \(error)")
                            }
                        }

                    case .failure(let error):
                        Logger.profile.error("Error saving profile pic \(error)")
                        self.error = SnapCatError(parseError: error)
                    }
                }
                objectWillChange.send()
            }
        }
    }
    private var isSettingForFirstTime = true

    // swiftlint:disable:next cyclomatic_complexity
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
        Utility.fetchImage(self.user.profileImage) { image in
            self.isSettingForFirstTime = true
            self.profilePicture = image
            self.isSettingForFirstTime = false
        }
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
        Self.queryFollowers().find { result in
            switch result {

            case .success(let activities):
                self.currentUserFollowers = activities.compactMap { $0.fromUser }
            case .failure(let error):
                Logger.explore.error("Failed to query current followers: \(error)")
            }
        }
        Self.queryFollowings().find { result in
            switch result {

            case .success(let activities):
                self.currentUserFollowings = activities.compactMap { $0.toUser }
            case .failure(let error):
                Logger.explore.error("Failed to query current followings: \(error)")
            }
        }
    }

    // MARK: Intents
    func followUser() {
        do {
            let newActivity = try Activity(type: .follow, from: User.current, to: user)
                .setupForFollowing()
            newActivity.save { result in
                if case .failure(let error) = result {
                    Logger.profile.error("Couldn't save follow: \(error)")
                }
            }
        } catch {
            Logger.profile.error("Can't create follow activity \(error.localizedDescription)")
        }
    }

    func unfollowUser() {
        do {
            guard let currentUser = User.current else {
                return
            }
            let query = try Activity.query(ActivityKey.fromUser == currentUser,
                                           ActivityKey.toUser == user,
                                           ActivityKey.type == Activity.ActionType.follow)
            query.first { result in
                switch result {

                case .success(let activity):
                    activity.delete { result in
                        if case .failure(let error) = result {
                            Logger.profile.error("Couldn't unfollow user \(error)")
                        }
                    }
                case .failure(let error):
                    Logger.profile.error("Couldn't find activity to unfollow \(error)")
                }
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

    // swiftlint:disable:next function_body_length
    func saveUpdates(completion: @escaping (Result<User, SnapCatError>) -> Void) {
        guard var currentUser = User.current else {
            let snapCatError = SnapCatError(message: "Trying to save when user isn't logged in")
            Logger.profile.error("\(snapCatError.message)")
            completion(.failure(snapCatError))
            return
        }
        if !currentUser.hasSameObjectId(as: user) {
            let snapCatError = SnapCatError(message: "Trying to save when this isn't the logged in user")
            Logger.profile.error("\(snapCatError.message)")
            completion(.failure(snapCatError))
            return
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
            currentUser.save { result in
                switch result {

                case .success(let user):
                    Logger.profile.info("User saved updates")
                    self.user = user
                    self.isHasChanges = false
                    completion(.success(user))
                case .failure(let error):
                    Logger.profile.error("Couldn't save user updates: \(error)")
                    self.error = SnapCatError(parseError: error)
                    completion(.failure(self.error!))
                }
            }
        } else {
            let snapCatError = SnapCatError(message: "No new changes to save")
            Logger.profile.debug("\(snapCatError.message)")
            completion(.failure(snapCatError))
        }
    }

    func resetPassword(completion: @escaping (Result<Void, SnapCatError>) -> Void) {
        guard let email = User.current?.email else {
            self.error = SnapCatError(message: "Need to save a valid email address before reseting password")
            completion(.failure(self.error!))
            return
        }
        User.passwordReset(email: email) { result in
            switch result {

            case .success:
                completion(.success(()))
            case .failure(let error):
                self.error = SnapCatError(parseError: error)
                completion(.failure(self.error!))
            }
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
