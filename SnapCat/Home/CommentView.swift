//
//  CommentView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct CommentView: View {
    @ObservedObject var viewModel: CommentViewModel
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Add a comment", text: $viewModel.comment)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(Text("Comment"))
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                viewModel.save { result in
                    if case .success(let comment) = result {
                        if let postId = viewModel.activity?.post?.id {
                            timeLineViewModel.comments[postId]?.insert(comment, at: 0)
                        }
                    }
                }
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Done")
            }))
        }
    }

    init(timeLineViewModel: QueryImageViewModel<Post>,
         post: Post,
         activity: Activity? = nil) {
        self.timeLineViewModel = timeLineViewModel
        viewModel = CommentViewModel(post: post, activity: activity)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(timeLineViewModel: .init(query: Post.query()), post: Post())
    }
}
