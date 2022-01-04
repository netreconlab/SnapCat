//
//  ParseSwift+extention.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

// swiftlint:disable line_length

extension ParseSwift {
    /** Can setup a connection to Parse Server based on a ParseCareKit.plist file.
    
   The key/values supported in the file are a dictionary named `ParseClientConfiguration`:
    - Server - (String) The server URL to connect to Parse Server.
    - ApplicationID - (String) The application id of your Parse application.
    - ClientKey - (String) The client key of your Parse application.
    - LiveQueryServer - (String) The live query server URL to connect to Parse Server.
    - UseTransactions - (Boolean) Use transactions inside the Client SDK.
    - parameter authentication: A callback block that will be used to receive/accept/decline network challenges.
     Defaults to `nil` in which the SDK will use the default OS authentication methods for challenges.
     It should have the following argument signature: `(challenge: URLAuthenticationChallenge,
     completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void`.
     See Apple's [documentation](https://developer.apple.com/documentation/foundation/urlsessiontaskdelegate/1411595-urlsession) for more for details.
     */
    static func setupServer(authentication: ((URLAuthenticationChallenge,
                                                     (URLSession.AuthChallengeDisposition,
                                                      URLCredential?) -> Void) -> Void)? = nil) {
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        var parseDictionary: [String: AnyObject]
        var clientKey: String?
        var liveQueryURL: URL?
        var useTransactions = false
        var cacheMemoryCapacity = 512_000
        var cacheDiskCapacity = 10_000_000
        guard let path = Bundle.main.path(forResource: "ParseSwift", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) else {
                fatalError("Error in ParseCareKit.setupServer(). Can't find ParseCareKit.plist in this project")
        }
        do {
            parseDictionary =
                try PropertyListSerialization.propertyList(from: xml,
                                                           options: .mutableContainersAndLeaves,
                                                           // swiftlint:disable:next force_cast
                                                           format: &propertyListFormat) as! [String: AnyObject]
        } catch {
            fatalError("Error in ParseCareKit.setupServer(). Couldn't serialize plist. \(error)")
        }

        guard let appID = parseDictionary["ApplicationID"] as? String,
            let server = parseDictionary["Server"] as? String,
            let serverURL = URL(string: server) else {
                fatalError("Error in ParseCareKit.setupServer()")
        }

        if let client = parseDictionary["ClientKey"] as? String {
            clientKey = client
        }

        if let liveQuery = parseDictionary["LiveQueryServer"] as? String {
            liveQueryURL = URL(string: liveQuery)
        }

        if let transactions = parseDictionary["UseTransactionsInternally"] as? Bool {
            useTransactions = transactions
        }

        if let capacity = parseDictionary["CacheMemoryCapacity"] as? Int {
            cacheMemoryCapacity = capacity
        }

        if let capacity = parseDictionary["CacheDiskCapacity"] as? Int {
            cacheDiskCapacity = capacity
        }

        ParseSwift.initialize(applicationId: appID,
                              clientKey: clientKey,
                              serverURL: serverURL,
                              liveQueryServerURL: liveQueryURL,
                              isUsingTransactions: useTransactions,
                              requestCachePolicy: .reloadIgnoringLocalCacheData,
                              cacheMemoryCapacity: cacheMemoryCapacity,
                              cacheDiskCapacity: cacheDiskCapacity,
                              authentication: authentication)
    }
}
