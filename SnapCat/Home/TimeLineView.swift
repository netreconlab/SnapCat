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

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if !timeLineViewModel.results.isEmpty {
                    List(timeLineViewModel.results, id: \.objectId) { result in
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
                                if timeLineViewModel.likes[currentObjectId] != nil {
                                    Image(systemName: "heart.fill")
                                } else {
                                    Image(systemName: "heart")
                                }
                                Image(systemName: "bubble.left")
                                Spacer()
                            }
                            HStack {
                                if let likes = timeLineViewModel.likes[currentObjectId] {
                                    Text("Liked by ")
                                    if likes.count > 2 {
                                        if let lastLikeUsername = likes.last?.fromUser?.username {
                                            Text("\(lastLikeUsername) ")
                                                .font(.headline)
                                        }
                                        Text("and \(likes.count - 1) others")
                                    } else {
                                        Text("\(likes.count) people")
                                    }
                                    Spacer()
                                }
                            }
                            HStack {
                                if let comments = timeLineViewModel.comments[currentObjectId] {
                                    if let lastComment = comments.last?.comment {
                                        Text(lastComment)
                                    }
                                    if comments.count > 1 {
                                        Text("View all \(comments.count)")
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
            }.onAppear(perform: {
                timeLineViewModel.find()
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
