//
//  TimeLineViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/5/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift

class TimeLineViewModel: ObservableObject {

    // MARK: Intents
    class func likePost(_ post: Post,
                        currentLikes: [Activity]?,
                        completion: @escaping (Activity, Activity.LikeState) -> Void) {
        guard let alreadyLikes = currentLikes?
                .first(where: { User.current?.id == $0.fromUser?.id }) else {
            let likeActivity = Activity.like(post: post)
            likeActivity.save { result in
                switch result {

                case .success(let liked):
                    completion(liked, .like)
                case .failure(let error):
                    Logger.home.error("Error liking post \(post): Error: \(error)")
                    completion(likeActivity, .error)
                }
            }
            return
        }
        alreadyLikes.delete { result in
            switch result {

            case .success:
                completion(alreadyLikes, .unlike)
            case .failure(let error):
                Logger.home.error("Error deleting like: \(error)")
                completion(alreadyLikes, .error)
            }
        }
        return
    }

    // MARK: Queries
    class func queryTimeLine() -> Query<Post> {
        guard let pointer = try? User.current?.toPointer() else {
            Logger.home.error("Should have created pointer.")
            return Post.query().limit(0)
        }

        let findFollowings = ProfileViewModel.queryFollowings()
        let findTimeLineData = Post.query(matchesKeyInQuery(key: PostKey.user,
                                                            queryKey: ActivityKey.toUser,
                                                            query: findFollowings))
        let findTimeLineDataForCurrentUser = Post.query(PostKey.user == pointer)
        let subQueries = [findTimeLineData, findTimeLineDataForCurrentUser]
        let query = Post.query(or(queries: subQueries))
            .order([.descending(ParseKey.createdAt)])
        return query
    }
}
