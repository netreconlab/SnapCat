//
//  ExploreView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ExploreView: View {

    @ObservedObject var viewModel = ExploreViewModel()
    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    @State var searchText: String = ""

    var body: some View {
        VStack {
            if !viewModel.users.isEmpty {
                // NavigationView {
                    VStack {
                        SearchBarView(searchText: $searchText)
                        ForEach(viewModel
                                    .users
                                    .filter({
                                        // swiftlint:disable:next line_length
                                        searchText == "" ? true : $0.username!.lowercased().contains(searchText.lowercased())
                                    }), id: \.id) { user in
                            /*NavigationLink(destination: ProfileView(user: user), label: {*/

                                HStack {

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
                                        if let name = user.name {
                                            Text(name)
                                                .font(.footnote)
                                        }
                                    }
                                    Spacer()

                                    Button(action: {
                                        viewModel.followUser(user)
                                    }, label: {
                                        Text("Follow")
                                            .foregroundColor(Color(tintColor))
                                            .padding()
                                            .border(Color(tintColor))
                                    })
                                }
                            // })
                        }
                    }
                    .padding()
                // }
                Spacer()
            } else {
                EmptyExploreView()
            }
        }.onAppear(perform: {
            viewModel.queryUsersNotFollowing()
        })
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
