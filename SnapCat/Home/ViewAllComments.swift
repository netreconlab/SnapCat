//
//  ViewAllComments.swift
//  SnapCat
//
//  Created by Corey Baker on 7/17/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ViewAllComments: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var post: Post
    var body: some View {
        if let comments = timeLineViewModel.comments[post.id] {
            NavigationView {
                List(comments, id: \.id) { result in
                    VStack(alignment: .leading) {
                        HStack {
                            if let username = result.fromUser?.username {
                                Text("\(username)")
                                    .font(.headline)
                            }
                            if let lastComment = result.comment {
                                Text(lastComment)
                            }
                        }
                        Divider()
                            .padding()
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle(Text("Comments"))
                .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                }), trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Done")
                }))
                Text("Hello")
                Spacer()
            }
        }
        Text("")
    }
}

struct ViewAllComments_Previews: PreviewProvider {
    static var previews: some View {
        ViewAllComments(timeLineViewModel: .init(query: Post.query()),
                        post: Post())
    }
}
