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
            if !viewModel.notFollowing.isEmpty {
                SearchBarView(searchText: $searchText)
                List(viewModel
                        .notFollowing
                        .filter({
                            searchText == "" ? true : $0.username!.lowercased().contains(searchText.lowercased())
                        })) { user in
                    HStack {
                        /*if let thumbnail = user.profileThumbnail {
                            thumbnail.fetch { result in
                                switch result {
                                case .success(let image):
                                    if let url = image.localURL {
                                        Image(url)
                                    } else {
                                        Image(systemName: "person.2.circle")
                                    }
                                case .failure(let error):
                                    Image(systemName: "person.2.circle")
                                }
                            }
                        } else {*/
                            Image(systemName: "person.circle")
                        // }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("@\(user.username!)")
                                    .font(.headline)
                                Button(action: {
                                    viewModel.followUser(user)
                                }, label: {
                                    Text("Follow")
                                        .foregroundColor(Color(tintColor))
                                        .padding()
                                        .border(Color(tintColor))
                                })
                            }
                            if let createdAt = user.createdAt {
                                Text(createdAt.relativeTime)
                            }
                        }
                    }
                }
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
