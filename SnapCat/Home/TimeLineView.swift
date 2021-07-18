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
                        VStack {
                            TimeLineImageView(timeLineViewModel: timeLineViewModel, post: result)
                                .frame(width: 0.75 * geometry.size.width,
                                       height: 0.75 * geometry.size.width,
                                       alignment: .center)
                            TimeLineLikeCommentView(timeLineViewModel: timeLineViewModel,
                                                    post: result,
                                                    currentObjectId: currentObjectId)
                            TimeLineCommentsView(timeLineViewModel: timeLineViewModel, post: result)
                        }
                    }
                } else {
                    EmptyTimeLineView()
                }
                Spacer()
            }
            .onAppear(perform: {
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
