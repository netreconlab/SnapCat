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

class QueryImageViewModel<T: ParseObject>: QueryViewModel<T> {

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

    var postResults = [Post]() {
        willSet {
            newValue.forEach { object in
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
                if imageResults.count == Constants.numberOfImagesToDownload {
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
            }
        }
    }

    var userResults = [User]() {
        willSet {
            newValue.forEach { object in
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
}

// MARK: QueryImageViewModel
public extension Query {

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
