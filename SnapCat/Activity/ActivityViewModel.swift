//
//  ActivityViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift

class ActivityViewModel: ObservableObject {

    class var queryFollowingsActivity: Query<Activity> {
        let followings = ProfileViewModel.queryFollowings()
        return Activity.query(matchesKeyInQuery(key: ActivityKey.fromUser,
                                                queryKey: ActivityKey.toUser,
                                                query: followings))
            .order([.descending(ParseKey.createdAt)])
    }
}
