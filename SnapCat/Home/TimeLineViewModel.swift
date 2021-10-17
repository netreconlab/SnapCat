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

@MainActor
class TimeLineViewModel: ObservableObject {

    // MARK: Intents
    class func likePost(_ post: Post,
                        currentLikes: [Activity]?) async -> (Activity, Activity.LikeState) {
        guard let alreadyLikes = currentLikes?
                .first(where: { User.current?.id == $0.fromUser?.id }) else {
                    let likeActivity = Activity.like(post: post)
                    do {
                        let liked = try await likeActivity.save()
                        return (liked, .like)
                    } catch {
                        Logger.home.error("Error liking post \(post): Error: \(error.localizedDescription)")
                        return (likeActivity, .error)
                    }
        }
        do {
            try await alreadyLikes.delete()
            return (alreadyLikes, .unlike)
        } catch {
            Logger.home.error("Error deleting like: \(error.localizedDescription)")
            return (alreadyLikes, .error)
        }
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
