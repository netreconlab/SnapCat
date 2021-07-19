//
//  TimeLinePostView.swift
//  TimeLinePostView
//
//  Created by Corey Baker on 7/17/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct TimeLinePostView: View {
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var post: Post
    var body: some View {
        HStack {
            Spacer()
            if let image = timeLineViewModel.imageResults[post.id] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    // .clipShape(Rectangle())
                    .onTapGesture(count: 2) {
                        TimeLineViewModel.likePost(post,
                                                   currentLikes: timeLineViewModel
                                                    .likes[post.id]) { (activity, status) in
                            switch status {

                            case .like:
                                timeLineViewModel.likes[post.id]?.append(activity)
                            case .unlike:
                                timeLineViewModel.likes[post.id]?.removeAll(where: {$0.hasSameObjectId(as: activity)})
                            case .error:
                                break
                            }
                        }
                    }
                    .padding([.top, .bottom])
            } else {
                Image(systemName: "camera")
                    .resizable()
                    .clipShape(Rectangle())
            }
            Spacer()
        }
    }
}

struct TimeLineImageView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLinePostView(timeLineViewModel: .init(query: Post.query()), post: Post())
    }
}
