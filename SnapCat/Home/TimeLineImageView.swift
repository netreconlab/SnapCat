//
//  TimeLineImageView.swift
//  TimeLineImageView
//
//  Created by Corey Baker on 7/17/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct TimeLineImageView: View {
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var post: Post
    var body: some View {
        HStack {
            Spacer()
            if let image = timeLineViewModel.imageResults[post.id] {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(Rectangle())
                    .onTapGesture(count: 2) {
                        TimeLineViewModel.likePost(post,
                                                   currentLikes: timeLineViewModel
                                                    .likes[post.id])
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
        TimeLineImageView(timeLineViewModel: .init(query: Post.query()), post: Post())
    }
}
