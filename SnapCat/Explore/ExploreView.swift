//
//  ExploreView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ExploreView: View {

    @Environment(\.tintColor) private var tintColor
    @StateObject var viewModel = ExploreViewModel()
    @State var searchText: String = ""

    var body: some View {
        if !viewModel.users.isEmpty {
            VStack {
                SearchBarView(searchText: $searchText)
                ScrollView {
                    ForEach(viewModel
                                .users
                                .filter({
                                    // swiftlint:disable:next line_length
                                    searchText == "" ? true : $0.username!.lowercased().contains(searchText.lowercased())
                                }), id: \.id) { user in

                        HStack {
                            NavigationLink(destination: ProfileView(user: user, isShowingHeading: false), label: {
                                if let image = viewModel.profileImages[user.id] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 50, height: 50, alignment: .leading)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                            .overlay(Circle().stroke(Color(tintColor), lineWidth: 1))
                                        .padding()
                                } else {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 50, height: 50, alignment: .leading)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                            .overlay(Circle().stroke(Color(tintColor), lineWidth: 1))
                                        .padding()
                                }
                                VStack(alignment: .leading) {
                                    if let username = user.username {
                                        Text("@\(username)")
                                            .font(.headline)
                                    }
                                    HStack {
                                        if let name = user.name {
                                            Text(name)
                                                .font(.footnote)
                                        }
                                        if viewModel.isCurrentFollower(user) {
                                            Label("Follows You",
                                                  systemImage: "checkmark.square.fill")
                                        }
                                    }
                                }
                                Spacer()
                            })
                            if viewModel.isCurrentFollowing(user) {
                                Button(action: {
                                    viewModel.unfollowUser(user)
                                }, label: {
                                    Text("Unfollow")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color(#colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1)))
                                        .cornerRadius(15)
                                })
                            } else {
                                Button(action: {
                                    viewModel.followUser(user)
                                }, label: {
                                    Text("Follow")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)))
                                        .cornerRadius(15)
                                })
                            }
                        }
                        Divider()
                    }
                    .navigationBarHidden(true)
                    Spacer()
                }
                .padding()
            }.onAppear(perform: {
                viewModel.update()
            })
        } else {
            VStack {
                EmptyExploreView()
                    .onAppear(perform: {
                        viewModel.update()
                    })
                Spacer()
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
