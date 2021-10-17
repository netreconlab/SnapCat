//
//  TimeLinePostView.swift
//  TimeLinePostView
//
//  Created by Corey Baker on 7/17/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

// swiftlint:disable line_length

struct TimeLinePostView: View {
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var post: Post
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    if let image = timeLineViewModel.imageResults[post.id] {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 0.95 * geometry.size.width,
                                   height: 0.95 * geometry.size.width,
                                   alignment: .leading)
                            .clipShape(Rectangle())
                            .onTapGesture(count: 2) {
                                Task {
                                    let currentTimeLine = timeLineViewModel

                                    let (activity, status) = await TimeLineViewModel.likePost(post,
                                                                                              currentLikes: currentTimeLine
                                                                                                .likes[post.id])
                                    switch status {

                                    case .like:
                                        timeLineViewModel.likes[post.id]?.append(activity)
                                    case .unlike:
                                        timeLineViewModel
                                            .likes[post.id]?
                                            .removeAll(where: { $0.hasSameObjectId(as: activity) })
                                    case .error:
                                        break
                                    }
                                }
                            }
                        Spacer()
                    } else {
                        Image(systemName: "camera")
                            .resizable()
                            .clipShape(Rectangle())
                    }
                }
            }
        }
    }
}

struct TimeLineImageView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLinePostView(timeLineViewModel: .init(query: Post.query()),
                         post: Post())
    }
}
