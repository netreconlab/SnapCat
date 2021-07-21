//
//  ProfileHeaderView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/18/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ProfileHeaderView: View {
    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var isShowingPost = false
    @State var isShowingOptions = false
    var body: some View {
        HStack {
            if let username = viewModel.user.username {
                Text(username)
                    .font(.title)
                    .frame(alignment: .leading)
                    .padding()
            }
            Spacer()
            if viewModel.user.objectId == User.current?.objectId {
                Button(action: {
                    self.isShowingPost = true
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .foregroundColor(Color(tintColor))
                        .frame(width: 30, height: 30, alignment: .trailing)
                })
                Button(action: {
                    self.isShowingOptions = true
                }, label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .foregroundColor(Color(tintColor))
                        .frame(width: 30, height: 30, alignment: .trailing)
                        .padding([.trailing])
                })
            }
        }.fullScreenCover(isPresented: $isShowingPost, content: {
            PostView(timeLineViewModel: timeLineViewModel)
        }).sheet(isPresented: $isShowingOptions, onDismiss: {}, content: {
            SettingsView()
        })
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeaderView(viewModel: .init(user: User(),
                                           isShowingHeading: true),
                          timeLineViewModel: .init(query: Post.query()))
    }
}
