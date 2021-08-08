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
            objectWillChange.send()
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
                        post.fetch(includeKeys: [PostKey.user]) { result in
                            switch result {

                            case .success(let fetchPost):
                                if let parseObject = fetchPost as? T {
                                    self.results.insert(parseObject, at: 0)
                                }
                            case .failure(let error):
                                Logger.post.error("Couldn't fetch \(error)")
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
                        post.fetch(includeKeys: [PostKey.user]) { result in
                            switch result {

                            case .success(let fetchPost):
                                if let parseObject = fetchPost as? T {
                                    self.results[index] = parseObject
                                }
                            case .failure(let error):
                                Logger.post.error("Couldn't fetch \(error)")
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
                    PostViewModel
                        .queryLikes(post: object)
                        .find { results in
                            switch results {
                            case .success(let foundLikes):
                                self.likes[object.id] = foundLikes
                            case .failure(let error):
                                Logger.post.error("QueryImageViewModel: couldn't find likes: \(error)")
                            }
                        }
                }
                if comments[object.id] == nil {
                    PostViewModel
                        .queryComments(post: object)
                        .include(ActivityKey.fromUser)
                        .find { results in
                            switch results {
                            case .success(let foundComments):
                                self.comments[object.id] = foundComments
                            case .failure(let error):
                                Logger.post.error("QueryImageViewModel: couldn't find comments: \(error)")
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
                Utility.fetchImage(object.image) { image in
                    if let image = image {
                        self.imageResults[object.id] = image
                    }
                }
                Utility.fetchImage(object.user?.profileImage) { image in
                    if let image = image {
                        if let userObjectId = object.user?.id {
                            self.imageResults[userObjectId] = image
                        }
                    }
                }
            }
            objectWillChange.send()
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
                Utility.fetchImage(object.profileImage) { image in
                    if let image = image {
                        self.imageResults[object.id] = image
                    }
                }
            }
        }
    }

    var relatedUser = [String: User]()

    /// Contains all fetched images.
    var imageResults = [String: UIImage]() {
        willSet {
            objectWillChange.send()
        }
    }

    /// Contains all fetched thumbnail images.
    var thubmNailImageResults = [String: UIImage]() {
        willSet {
            objectWillChange.send()
        }
    }

    /// Contains likes for each post
    var likes = [String: [Activity]]() {
        willSet {
            objectWillChange.send()
        }
    }

    /// Contains comments for each post
    var comments = [String: [Activity]]() {
        willSet {
            objectWillChange.send()
        }
    }

    var postSelected: Post?

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
        try? ParseLiveQuery.client?.subscribeCustom(self)
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
        try client.subscribe(QueryImageViewModel(query: self))
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
