//
//  ProfileHeaderView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/18/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ProfileHeaderView: View {
    @Environment(\.tintColor) private var tintColor
    @StateObject var postStatus = PostStatus()
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var isShowingOptions = false
    var body: some View {
        HStack {
            NavigationLink(destination: PostView(timeLineViewModel: timeLineViewModel)
                            .environmentObject(postStatus),
                           isActive: $postStatus.isShowing) {
               EmptyView()
            }
            NavigationLink(destination: SettingsView(),
                           isActive: $isShowingOptions) {
               EmptyView()
            }
            if let username = viewModel.user.username {
                Text(username)
                    .font(.title)
                    .frame(alignment: .leading)
                    .padding()
            }
            Spacer()
            if viewModel.user.objectId == User.current?.objectId {
                Button(action: {
                    self.postStatus.isShowing = true
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .foregroundColor(Color(tintColor))
                        .frame(width: 30, height: 30, alignment: .trailing)
                })
                Button(action: {
                    self.isShowingOptions = true
                }, label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .foregroundColor(Color(tintColor))
                        .frame(width: 30, height: 30, alignment: .trailing)
                        .padding([.trailing])
                })
            }
        }
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeaderView(viewModel: .init(user: User(),
                                           isShowingHeading: true),
                          timeLineViewModel: .init(query: Post.query()))
            .environmentObject(PostStatus(isShowing: true))
    }
}
