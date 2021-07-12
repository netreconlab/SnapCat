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

    // MARK: Helper Methods

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
            .include(PostKey.user)
            .order([.descending(ParseKey.createdAt)])
        return query
    }
}
