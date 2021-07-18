//
//  TimeLineLikeCommentView.swift
//  TimeLineLikeCommentView
//
//  Created by Corey Baker on 7/17/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct TimeLineLikeCommentView: View {
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var post: Post
    @State var isShowingComment = false
    let currentObjectId: String
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if timeLineViewModel.isLikedPost(post,
                                                     userObjectId: currentObjectId) {
                        Image(systemName: "heart.fill")
                    } else {
                        Image(systemName: "heart")
                    }
                }.onTapGesture(count: 1) {
                    TimeLineViewModel.likePost(post,
                                               currentLikes: timeLineViewModel
                                                .likes[post.id])
                }
                VStack {
                    if timeLineViewModel.isCommentedOnPost(post,
                                                           userObjectId: currentObjectId) {
                        Image(systemName: "bubble.left.fill")
                    } else {
                        Image(systemName: "bubble.left")
                    }
                }.onTapGesture(count: 1) {
                    self.timeLineViewModel.postSelected = post
                    self.isShowingComment = true
                }
                Spacer()
            }
            HStack {
                if let likes = timeLineViewModel.likes[post.id] {
                    Text("Liked by")
                    if likes.count > 2 {
                        if let lastLikeUsername = likes.last?.fromUser?.username {
                            Text("\(lastLikeUsername) ")
                                .font(.headline)
                        }
                        Text("and \(likes.count - 1) others")
                    } else if likes.count == 1 {
                        Text("\(likes.count) person")
                    } else {
                        Text("\(likes.count) people")
                    }
                    Spacer()
                }
            }
            HStack {
                if let username = post.user?.username {
                    Text("\(username)")
                        .font(.headline)
                }
                if let caption = post.caption {
                    Text(caption)
                }
                Spacer()
            }
        }.sheet(isPresented: $isShowingComment, content: {
            if let post = timeLineViewModel.postSelected {
                CommentView(post: post)
            }
        })
    }
}

struct TimeLineLikeCommentView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineLikeCommentView(timeLineViewModel: .init(query: Post.query()), post: Post(), currentObjectId: "")
    }
}
