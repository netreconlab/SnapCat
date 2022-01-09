//
//  HomeView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct HomeView: View {

    @Environment(\.tintColor) private var tintColor
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @StateObject var postStatus = PostStatus()

    var body: some View {
        VStack {
            NavigationLink(destination: PostView(timeLineViewModel: timeLineViewModel)
                            .environmentObject(postStatus),
                           isActive: $postStatus.isShowing) {
               EmptyView()
            }
            HStack {
                Text("SnapCat")
                    .font(Font.custom("noteworthy-bold", size: 30))
                    .foregroundColor(Color(tintColor))
                    .padding()
                Spacer()
                Button(action: {
                    self.postStatus.isShowing = true
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .foregroundColor(Color(tintColor))
                        .frame(width: 30, height: 30, alignment: .trailing)
                        .padding()
                })
            }
            Divider()
            TimeLineView(viewModel: timeLineViewModel)
        }
    }

    init() {
        let timeLineQuery = TimeLineViewModel.queryTimeLine()
            .include(PostKey.user)
        if let timeLine = timeLineQuery.subscribeCustom {
            timeLineViewModel = timeLine
        } else {
            timeLineViewModel = timeLineQuery.imageViewModel
        }
        timeLineViewModel.find()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
