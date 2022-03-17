//
//  QueryImageViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/12/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift
import UIKit

class QueryImageViewModel<T: ParseObject>: Subscription<T> {

    override var results: [QueryViewModel<T>.Object] {
        willSet {
            count = newValue.count
            if let posts = newValue as? [Post] {
                postResults = posts
            } else if let users = newValue as? [User] {
                userResults = users
            }
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    override var event: (query: Query<T>, event: Event<T>)? {
        willSet {
            guard let event = newValue?.event else {
                return
            }
            switch event {

            case .created(let object), .entered(let object):
                if var post = object as? Post {
                    // LiveQuery doesn't include pointers, need to check to fetch
                    guard let userObjectId = post.user?.id,
                        let user = relatedUser[userObjectId] else {
                            let currentPost = post
                            Task {
                                do {
                                    let fetchPost = try await currentPost.fetch(includeKeys: [PostKey.user])
                                    if let parseObject = fetchPost as? T {
                                        self.results.insert(parseObject, at: 0)
                                    }
                                } catch {
                                    Logger.post.error("Couldn't fetch \(error.localizedDescription)")
                                }
                            }
                            return
                    }
                    post.user = user
                    if let parseObject = post as? T {
                        self.results.insert(parseObject, at: 0)
                    }
                }

            case .updated(let object):
                guard let index = results.firstIndex(where: { $0.hasSameObjectId(as: object) }) else {
                    return
                }
                if var post = object as? Post {
                    // LiveQuery doesn't include pointers, need to check to fetch
                    guard let userObjectId = post.user?.id,
                        let user = relatedUser[userObjectId] else {
                            let currentPost = post
                            Task {
                                do {
                                    let fetchPost = try await currentPost
                                        .fetch(includeKeys: [PostKey.user])
                                    if let parseObject = fetchPost as? T {
                                        self.results[index] = parseObject
                                    }
                                } catch {
                                    Logger.post.error("Couldn't fetch \(error.localizedDescription)")
                                }
                            }
                            return
                    }
                    post.user = user
                    if let parseObject = post as? T {
                        self.results[index] = parseObject
                    }
                }

            case .deleted(let object):
                guard let index = results.firstIndex(where: { $0.hasSameObjectId(as: object) }) else {
                    return
                }
                results.remove(at: index)
            default:
                break
            }
            subscribed = nil
            unsubscribed = nil
        }
    }

    var userOfInterest: User?

    var postResults = [Post]() {
        willSet {
            newValue.forEach { object in
                storeRelatedUser(object.user)
                if likes[object.id] == nil {
                    Task {
                        do {
                            let foundLikes = try await PostViewModel
                                .queryLikes(post: object)
                                .find()
                            DispatchQueue.main.async {
                                self.likes[object.id] = foundLikes
                            }
                        } catch {
                            Logger.post.error("QueryImageViewModel: couldn't find likes: \(error.localizedDescription)")
                        }
                    }
                }
                if comments[object.id] == nil {
                    Task {
                        do {
                            let foundComments = try await PostViewModel
                                .queryComments(post: object)
                                .include(ActivityKey.fromUser)
                                .find()
                            DispatchQueue.main.async {
                                self.comments[object.id] = foundComments
                            }
                        } catch {
                            // swiftlint:disable:next line_length
                            Logger.post.error("QueryImageViewModel: couldn't find comments: \(error.localizedDescription)")
                        }
                    }
                }
                // Fetch images
                if imageResults.count >= Constants.numberOfImagesToDownload {
                    return
                }
                guard imageResults[object.id] == nil else {
                    return
                }
                Task {
                    if let image = await Utility.fetchImage(object.image) {
                        DispatchQueue.main.async {
                            self.imageResults[object.id] = image
                        }
                    }
                }
                Task {
                    if let image = await Utility.fetchImage(object.user?.profileImage) {
                        if let userObjectId = object.user?.id {
                            DispatchQueue.main.async {
                                self.imageResults[userObjectId] = image
                            }
                        }
                    }

                }
            }
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    var userResults = [User]() {
        willSet {
            newValue.forEach { object in
                storeRelatedUser(object)
                // Fetch images
                if imageResults.count == Constants.numberOfImagesToDownload {
                    return
                }
                guard imageResults[object.id] == nil else {
                    return
                }
                Task {
                    if let image = await Utility.fetchImage(object.profileImage) {
                        DispatchQueue.main.async {
                            self.imageResults[object.id] = image
                        }
                    }
                }
            }
        }
    }

    /// Contains all fetched images.
    var imageResults = [String: UIImage]() {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    /// Contains all fetched thumbnail images.
    var thubmNailImageResults = [String: UIImage]() {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    /// Contains likes for each post
    var likes = [String: [Activity]]() {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    /// Contains comments for each post
    var comments = [String: [Activity]]() {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    var relatedUser = [String: User]()

    // MARK: Helpers
    func storeRelatedUser(_ user: User?) {
        guard let userObjectId = user?.id,
              relatedUser[userObjectId] == nil else {
            return
        }
        relatedUser[userObjectId] = user
    }

    func isLikedPost(_ post: Post, userObjectId: String? = nil) -> Bool {
        let userOfInterest: String!
        if let user = userObjectId {
            userOfInterest = user
        } else {
            guard let currentUser = User.current?.id else {
                Logger.home.error("User is suppose to be logged")
                return false
            }
            userOfInterest = currentUser
        }
        guard let activities = likes[post.id],
              activities.first(where: { $0.fromUser?.objectId == userOfInterest }) != nil else {
            return false
        }
        return true
    }

    func isCommentedOnPost(_ post: Post, userObjectId: String? = nil) -> Bool {
        let userOfInterest: String!
        if let user = userObjectId {
            userOfInterest = user
        } else {
            guard let currentUser = User.current?.id else {
                Logger.home.error("User is suppose to be logged")
                return false
            }
            userOfInterest = currentUser
        }
        guard let activities = comments[post.id],
              activities.first(where: { $0.fromUser?.objectId == userOfInterest }) != nil else {
            return false
        }
        return true
    }
}

// MARK: ParseLiveQuery
public extension ParseLiveQuery {
    internal func subscribeCustom<T>(_ query: Query<T>) throws -> QueryImageViewModel<T> {
        try subscribe(QueryImageViewModel(query: query))
    }
}

// MARK: QueryImageViewModel
public extension Query {

    /**
     Registers the query for live updates, using the default subscription handler,
     and the default `ParseLiveQuery` client. Suitable for `ObjectObserved`
     as the subscription can be used as a SwiftUI publisher. Meaning it can serve
     indepedently as a ViewModel in MVVM.
     */
    internal var subscribeCustom: QueryImageViewModel<ResultType>? {
        do {
            guard try ParseSwift.isServerAvailable() else {
                Logger.queryImageViewModel.error("Server health is not \"ok\"")
                return nil
            }
            return try? ParseLiveQuery.client?.subscribeCustom(self)
        } catch {
            Logger.queryImageViewModel.error("Server health: \(error.localizedDescription)")
            return nil
        }
    }

    /**
     Registers the query for live updates, using the default subscription handler,
     and a specific `ParseLiveQuery` client. Suitable for `ObjectObserved`
     as the subscription can be used as a SwiftUI publisher. Meaning it can serve
     indepedently as a ViewModel in MVVM.
     - parameter client: A specific client.
     - returns: The subscription that has just been registered
     */
    internal func subscribeCustom(_ client: ParseLiveQuery) throws -> QueryImageViewModel<ResultType> {
        guard try ParseSwift.isServerAvailable() else {
            let errorMessage = "Server health is not \"ok\""
            Logger.queryImageViewModel.error("\(errorMessage)")
            throw SnapCatError(message: errorMessage)
        }
        return try client.subscribe(QueryImageViewModel(query: self))
    }

    /**
     Creates a view model for this query. Suitable for `ObjectObserved`
     as the view model can be used as a SwiftUI publisher. Meaning it can serve
     indepedently as a ViewModel in MVVM.
     */
    internal var imageViewModel: QueryImageViewModel<ResultType> {
        QueryImageViewModel(query: self)
    }

    /**
     Creates a view model for this query. Suitable for `ObjectObserved`
     as the view model can be used as a SwiftUI publisher. Meaning it can serve
     indepedently as a ViewModel in MVVM.
     - parameter query: Any query.
     - returns: The view model for this query.
     */
    internal static func imageViewModel(_ query: Self) -> QueryImageViewModel<ResultType> {
        QueryImageViewModel(query: query)
    }
}
