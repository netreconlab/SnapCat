//
//  TimeLineView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/5/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift
import os.log
import UIKit

struct TimeLineView: View {

    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    let currentObjectId: String
    @State var isShowingComment = false
    @State var isShowingAllComments = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if !timeLineViewModel.results.isEmpty {
                    List(timeLineViewModel.results, id: \.id) { result in
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                if let image = timeLineViewModel.imageResults[result.id] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 0.75 * geometry.size.width,
                                               height: 0.75 * geometry.size.width,
                                               alignment: .center)
                                        .clipShape(Rectangle())
                                        .onTapGesture(count: 2) {
                                            TimeLineViewModel.likePost(result,
                                                                       currentLikes: timeLineViewModel
                                                                        .likes[result.id])
                                        }
                                        .padding([.top, .bottom])
                                } else {
                                    Image(systemName: "camera")
                                        .resizable()
                                        .frame(width: 0.75 * geometry.size.width,
                                               height: 0.75 * geometry.size.width,
                                               alignment: .center)
                                        .clipShape(Rectangle())
                                }
                                Spacer()
                            }
                            HStack {
                                VStack {
                                    if timeLineViewModel.isLikedPost(result,
                                                                     userObjectId: currentObjectId) {
                                        Image(systemName: "heart.fill")
                                    } else {
                                        Image(systemName: "heart")
                                    }
                                }.onTapGesture(count: 1) {
                                    TimeLineViewModel.likePost(result,
                                                               currentLikes: timeLineViewModel
                                                                .likes[result.id])
                                }
                                VStack {
                                    if timeLineViewModel.isCommentedOnPost(result,
                                                                           userObjectId: currentObjectId) {
                                        Image(systemName: "bubble.left.fill")
                                    } else {
                                        Image(systemName: "bubble.left")
                                    }
                                }.onTapGesture(count: 1) {
                                    self.timeLineViewModel.postSelected = result
                                    self.isShowingComment = true
                                }
                                Spacer()
                            }
                            HStack {
                                if let likes = timeLineViewModel.likes[result.id] {
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
                                if let username = result.user?.username {
                                    Text("\(username)")
                                        .font(.headline)
                                }
                                if let caption = result.caption {
                                    Text(caption)
                                }
                            }
                            if let comments = timeLineViewModel.comments[result.id],
                               comments.count > 0 {
                                if comments.count > 1 {
                                    Text("View all \(comments.count)")
                                        .font(.footnote)
                                        .onTapGesture(count: 1) {
                                            self.timeLineViewModel.postSelected = result
                                            self.isShowingAllComments = true
                                        }
                                }
                                HStack {
                                    if let username = comments.last?.fromUser?.username {
                                        Text("\(username)")
                                            .font(.headline)
                                    }
                                    if let lastComment = comments.last?.comment {
                                        Text(lastComment)
                                    }
                                }
                                Spacer()
                            }
                            if let createdAt = result.createdAt {
                                Text(createdAt.relativeTime)
                                    .font(.footnote)
                            }
                        }
                    }.frame(alignment: .top)
                } else {
                    EmptyTimeLineView()
                }
                Spacer()
            }
            .onAppear(perform: {
                timeLineViewModel.find()
            })
            .sheet(isPresented: $isShowingComment, content: {
                if let post = timeLineViewModel.postSelected {
                    CommentView(post: post)
                }
            })
            .fullScreenCover(isPresented: $isShowingAllComments, content: {
                if let post = timeLineViewModel.postSelected {
                    ViewAllComments(timeLineViewModel: timeLineViewModel,
                                    post: post)
                }
            })
        }
    }

    init(viewModel: QueryImageViewModel<Post>? = nil) {
        if let objectId = User.current?.id {
            currentObjectId = objectId
        } else {
            currentObjectId = ""
        }
        guard let viewModel = viewModel else {
            timeLineViewModel = TimeLineViewModel.queryTimeLine()
                .include(PostKey.user)
                .imageViewModel
            timeLineViewModel.find()
            return
        }
        timeLineViewModel = viewModel
    }
}

struct TimeLineView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineView()
    }
}
