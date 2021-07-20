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

    let currentObjectId: String
    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1) }
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var isShowingProfile = false
    @State var gradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1)), Color(#colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1))]),
                                         startPoint: .top,
                                         endPoint: .bottom)
    var body: some View {
        if !timeLineViewModel.results.isEmpty {
            NavigationView {
                List(timeLineViewModel.results, id: \.id) { result in
                    VStack {
                        HStack {
                            if let userObjectId = result.user?.id,
                                let image = timeLineViewModel.imageResults[userObjectId] {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 40, height: 40, alignment: .leading)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                        .overlay(Circle().stroke(gradient, lineWidth: 3))
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40, alignment: .leading)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                        .overlay(Circle().stroke(gradient, lineWidth: 1))
                            }
                            if let username = result.user?.username {
                                Text("\(username)")
                                    .font(.headline)
                            }
                            Spacer()
                        }.onTapGesture(count: 1) {
                            self.timeLineViewModel.userOfInterest = result.user
                            self.isShowingProfile = true
                        }
                        TimeLinePostView(timeLineViewModel: timeLineViewModel,
                                         post: result)
                            .scaledToFill()
                            .padding(.bottom)
                        TimeLineLikeCommentView(timeLineViewModel: timeLineViewModel,
                                                post: result,
                                                currentObjectId: currentObjectId)
                        TimeLineCommentsView(timeLineViewModel: timeLineViewModel, post: result)

                        Spacer()
                    }
                }.navigationBarHidden(true)
            }.onAppear(perform: {
                timeLineViewModel.find()
            }).sheet(isPresented: $isShowingProfile, content: {
                ProfileView(user: self.timeLineViewModel.userOfInterest,
                            isShowingHeading: false)
            })
        } else {
            VStack {
                EmptyTimeLineView()
                Spacer()
            }
        }
    }

    init(viewModel: QueryImageViewModel<Post>? = nil) {
        if let objectId = User.current?.id {
            currentObjectId = objectId
        } else {
            currentObjectId = ""
        }
        guard let viewModel = viewModel else {
            let timeLineQuery = TimeLineViewModel.queryTimeLine()
                .include(PostKey.user)
            if let timeLine = timeLineQuery.subscribeCustom {
                timeLineViewModel = timeLine
            } else {
                timeLineViewModel = timeLineQuery.imageViewModel
            }
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
