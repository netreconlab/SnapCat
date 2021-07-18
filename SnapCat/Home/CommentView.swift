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
                viewModel.save()
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Done")
            }))
        }
    }

    init(post: Post, activity: Activity? = nil) {
        viewModel = CommentViewModel(post: post, activity: activity)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(post: Post())
    }
}
