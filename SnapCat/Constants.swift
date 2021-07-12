//
//  Constants.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

enum Constants {
    static let firstRun                         = "FirstRun"
    static let lastProfilePicURL                = "lastProfilePicURL"
}

// MARK: - Standard Parse Class Keys
enum ParseKey {
    static let objectId = "objectId"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
    static let ACL = "ACL"
}

// MARK: - User Class Keys
enum UserKey {
    static let username                                 = "username"
    static let password                                 = "password"
    static let email                                    = "email"
    static let emailVerified                            = "emailVerified"
    static let authData                                 = "authData"
    static let name                                     = "name"
    static let profileImage                             = "profileImage"
    static let profileThumbnail                         = "profileThumbnail"
    static let bio                                      = "bio"
    static let link                                     = "link"
}

// MARK: - Installation Class Keys
enum InstallationKey {
    static let deviceType                               = "deviceType"
    static let installationId                           = "installationId"
    static let deviceToken                              = "deviceToken"
    static let badge                                    = "badge"
    static let timeZone                                 = "timeZone"
    static let channels                                 = "channels"
    static let appName                                  = "appName"
    static let appIdentifier                            = "appIdentifier"
    static let parseVersion                             = "parseVersion"
    static let localeIdentifier                         = "localeIdentifier"
}

// MARK: - Activity Class Keys
enum ActivityKey {
    static let fromUser                                 = "fromUser"
    static let toUser                                   = "toUser"
    static let type                                     = "type"
    static let comment                                  = "comment"
    static let post                                     = "post"
    static let activity                                 = "activity"
}

// MARK: - Post Class Keys
enum PostKey {
    static let user                                     = "user"
    static let image                                    = "image"
    static let thumbnail                                = "thumbnail"
    static let postedAt                                 = "postedAt"
    static let location                                 = "location"
    static let caption                                  = "caption"
}
