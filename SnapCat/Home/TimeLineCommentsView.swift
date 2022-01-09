//
//  TimeLineCommentsView.swift
//  TimeLineCommentsView
//
//  Created by Corey Baker on 7/17/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct TimeLineCommentsView: View {
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var post: Post
    @State var isShowingAllComments = false
    @State var postSelected = Post()
    var body: some View {
        VStack {
            if let comments = timeLineViewModel.comments[post.id],
               comments.count > 0 {
                NavigationLink(destination: ViewAllComments(timeLineViewModel: timeLineViewModel,
                                                            post: post),
                               isActive: $isShowingAllComments) {
                   EmptyView()
                }
                if comments.count > 1 {
                    HStack {
                        Text("View all \(comments.count) comments")
                            .font(.footnote)
                            .onTapGesture(count: 1) {
                                self.timeLineViewModel.postSelected = post
                                self.postSelected = post
                                self.isShowingAllComments = true
                            }
                        Spacer()
                    }
                }
                HStack {
                    if let username = comments.first?.fromUser?.username {
                        Text("\(username)")
                            .font(.headline)
                    }
                    if let lastComment = comments.first?.comment {
                        Text(lastComment)
                    }
                    Spacer()
                }
            }
            if let createdAt = post.createdAt {
                HStack {
                    Text(createdAt.relativeTime)
                        .font(.footnote)
                    Spacer()
                }
            }
        }
    }
}

struct TimeLineCommentsView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineCommentsView(timeLineViewModel: .init(query: Post.query()), post: Post())
    }
}
