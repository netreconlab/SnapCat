//
//  ProfileView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct ProfileView: View {
    @Environment(\.tintColor) private var tintColor
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @ObservedObject var followersViewModel: QueryViewModel<Activity>
    @ObservedObject var followingsViewModel: QueryViewModel<Activity>
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            if viewModel.isShowingHeading {
                ProfileHeaderView(viewModel: viewModel,
                                  timeLineViewModel: timeLineViewModel)
            } else {
                HStack {
                    if let username = viewModel.user.username {
                        Text(username)
                            .font(.title)
                            .frame(alignment: .leading)
                            .padding()
                    }
                    if viewModel.isCurrentFollower() {
                        Label("Follows You",
                              systemImage: "checkmark.square.fill")
                    }
                    Spacer()
                }
            }
            ProfileUserDetailsView(viewModel: viewModel,
                                   followersViewModel: followersViewModel,
                                   followingsViewModel: followingsViewModel,
                                   timeLineViewModel: timeLineViewModel)
            Divider()
            TimeLineView(viewModel: timeLineViewModel)
        }.onAppear(perform: {
            followersViewModel.find()
            followingsViewModel.find()
        })
    }

    init(user: User? = nil, isShowingHeading: Bool = true) {
        var userProfile: User!
        if let user = user {
            userProfile = user
        } else if let currentUser = User.current {
            userProfile = currentUser
        } else {
            userProfile = User()
        }
        viewModel = ProfileViewModel(user: userProfile,
                                     isShowingHeading: isShowingHeading)
        let timeLineQuery = ProfileViewModel
            .queryUserTimeLine(userProfile)
            .include(PostKey.user)
        if let timeLine = timeLineQuery.subscribeCustom {
            timeLineViewModel = timeLine
        } else {
            timeLineViewModel = timeLineQuery.imageViewModel
        }
        followersViewModel = ProfileViewModel
            .queryFollowers(userProfile)
            .include(ActivityKey.fromUser)
            .viewModel
        followingsViewModel = ProfileViewModel
            .queryFollowings(userProfile)
            .include(ActivityKey.toUser)
            .viewModel
        timeLineViewModel.find()
        followersViewModel.find()
        followingsViewModel.find()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
