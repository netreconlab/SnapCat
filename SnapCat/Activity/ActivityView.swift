//
//  ActivityView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var followingsActivityViewModel = ActivityViewModel
        .queryFollowingsActivity
        .include(ActivityKey.fromUser)
        .include(ActivityKey.toUser)
        .viewModel

    var body: some View {
        NavigationView {
            if !followingsActivityViewModel.results.isEmpty {
                List(followingsActivityViewModel.results, id: \.id) { result in
                    VStack {
                        HStack {
                            if let fromUsername = result.fromUser?.username {
                                Text("@\(fromUsername)")
                                    .font(.headline)
                            }
                            if let activity = result.type {
                                switch activity {
                                case .like:
                                    Text("liked")
                                case .follow:
                                    Text("followed")
                                case .comment:
                                    Text("commented on")
                                }
                            }
                            if let fromUsername = result.toUser?.username {
                                Text("@\(fromUsername)")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        if let createdAt = result.createdAt {
                            HStack {
                                Text(createdAt.relativeTime)
                                    .font(.footnote)
                                Spacer()
                            }
                        }
                    }
                }
                Spacer()
            } else {
                EmptyActivityView()
            }
        }.onAppear(perform: {
            followingsActivityViewModel.find()
        })
    }

    init () {
        followingsActivityViewModel.find()
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
