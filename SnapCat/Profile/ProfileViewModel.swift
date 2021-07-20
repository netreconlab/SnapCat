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
import UIKit

// swiftlint:disable type_body_length
class ProfileViewModel: ObservableObject {

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
    private var settingProfilePicForFirstTime = true
    var profilePicture = UIImage(systemName: "person.circle") {
        willSet {
            if !isSettingForFirstTime {
                guard let currentUser = User.current,
                      currentUser.hasSameObjectId(as: user),
                      let image = newValue,
                      let compressed = image.compressTo(3) else {
                    return
                }
                let newProfilePicture = ParseFile(name: "profile.jpeg", data: compressed)
                user.profileImage = newProfilePicture
                user.save { result in
                    switch result {

                    case .success(let user):

                        user.fetch { result in
                            switch result {

                            case .success(let fetchedUser):

                                fetchedUser.profileImage?.fetch { result in
                                    switch result {

                                    case .success(let profilePic):
                                        if let path = profilePic.localURL?.relativePath {
                                            // If there's a newer file in the cloud, need to fetch it
                                            UserDefaults.standard.setValue(path, forKey: Constants.lastProfilePicURL)
                                            UserDefaults.standard.synchronize()
                                        }
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

    init(user: User?) {
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
    }

    func checkCacheForProfileImage() {
        let cachedProfilePicURL = UserDefaults.standard.value(forKey: Constants.lastProfilePicURL) as? String

        if let cachedProfileURL = cachedProfilePicURL {
            profilePicture = UIImage(contentsOfFile: cachedProfileURL)
        }
        let cachedProfileFileName = Utility.getFileNameFromPath(cachedProfilePicURL)
        // If there's a newer file in the cloud, need to fetch it
        if cachedProfileFileName != User.current?.profileImage?.name || self.profilePicture == nil {
            if let cachedURL = cachedProfilePicURL {
                try? Utility.removeFilesAtDirectory(cachedURL,
                                                    isDirectory: false)
            }
            if let image = User.current?.profileImage {
                image.fetch { fetchResult in
                    switch fetchResult {

                    case .success(let profilePicture):
                        if let path = profilePicture.localURL?.relativePath {
                            self.profilePicture = UIImage(contentsOfFile: path)
                            UserDefaults.standard.setValue(path, forKey: Constants.lastProfilePicURL)
                            UserDefaults.standard.synchronize()
                        }
                        self.settingProfilePicForFirstTime = false
                    case .failure(let error):
                        Logger.profile.error("Couldn't fetch profile pic: \(error)")
                        self.settingProfilePicForFirstTime = false
                    }
                }
            } else {
                self.settingProfilePicForFirstTime = false
            }
        } else {
            self.settingProfilePicForFirstTime = false
        }
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
        guard let currentUser = User.current else {
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
            User.current?.username = username
            changesNeedToBeSaved = true
        }
        if email != user.email && !email.isEmpty {
            User.current?.email = email
            changesNeedToBeSaved = true
        }
        if name != user.name && !name.isEmpty {
            User.current?.name = name
            changesNeedToBeSaved = true
        }
        if bio != user.bio && !bio.isEmpty {
            User.current?.bio = bio
            changesNeedToBeSaved = true
        }
        if URL(string: link) != user.link && !link.isEmpty {
            User.current?.link = URL(string: link)
            changesNeedToBeSaved = true
        }
        if changesNeedToBeSaved {
            User.current?.save { result in
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
