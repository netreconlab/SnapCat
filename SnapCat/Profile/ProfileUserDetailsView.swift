//
//  ProfileUserDetailsView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/18/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct ProfileUserDetailsView: View {
    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var followersViewModel: QueryViewModel<Activity>
    @ObservedObject var followingsViewModel: QueryViewModel<Activity>
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var isShowingImagePicker = false
    @State var isShowingEditProfile = false
    @State var isShowingExplorer = false
    @State var explorerView = ExploreView()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isShowingImagePicker = true
                }, label: {
                    if let image = viewModel.profilePicture {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 90, height: 90, alignment: .leading)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .overlay(Circle().stroke(Color(tintColor), lineWidth: 1))
                            .padding()
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 90, height: 90, alignment: .leading)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .overlay(Circle().stroke(Color(tintColor), lineWidth: 1))
                            .padding()
                    }
                })
                .buttonStyle(PlainButtonStyle())
                Spacer()
                VStack {
                    Text("\(timeLineViewModel.results.count)")
                        .padding(.trailing)
                    Text("Posts")
                        .padding(.trailing)
                }
                Button(action: {
                    self.explorerView = ExploreView(viewModel: .init(users: ProfileViewModel
                                                                .getUsersFromFollowers(followersViewModel
                                                                                        .results)), searchText: "")
                    self.isShowingExplorer = true
                }, label: {
                    VStack {
                        Text("\(followersViewModel.results.count)")
                            .padding(.trailing)
                        Text("Followers")
                            .padding(.trailing)
                    }
                })
                .buttonStyle(PlainButtonStyle())
                Button(action: {
                    self.explorerView = ExploreView(viewModel: .init(users: ProfileViewModel
                                                                .getUsersFromFollowings(followingsViewModel
                                                                                        .results)), searchText: "")
                    self.isShowingExplorer = true
                }, label: {
                    VStack {
                        Text("\(followingsViewModel.results.count)")
                            .padding(.trailing)
                        Text("Following")
                            .padding(.trailing)
                    }
                })
                .buttonStyle(PlainButtonStyle())
            }
            HStack {
                VStack(alignment: .leading) {
                    if let name = viewModel.user.name {
                        Text(name)
                            .padding([.leading])
                            .font(.title2)
                    }
                    if let bio = viewModel.user.bio {
                        Text(bio)
                            .padding([.leading])
                    }
                    if let link = viewModel.user.link {
                        Link(destination: link, label: {
                            Text("\(link.absoluteString)")
                        })
                        .padding([.leading])
                    }
                }
                Spacer()
            }
            if viewModel.user.objectId == User.current?.objectId {
                Button(action: {
                    self.isShowingEditProfile = true
                }, label: {
                    Text("Edit Profile")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(Color(tintColor))
                        .padding()
                        .cornerRadius(15)
                        .border(Color(tintColor))
                })
                .padding([.leading, .trailing], 20)
            }
        }.sheet(isPresented: $isShowingImagePicker, onDismiss: {}, content: {
            ImagePickerView(image: $viewModel.profilePicture)
        }).sheet(isPresented: $isShowingEditProfile, onDismiss: {}, content: {
            ProfileEditView(viewModel: viewModel)
        })
        .sheet(isPresented: $isShowingExplorer, onDismiss: {}, content: {
            self.explorerView
        })
    }
}

struct ProfileUserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileUserDetailsView(viewModel: .init(user: User()),
                               followersViewModel: .init(query: Activity.query()),
                               followingsViewModel: .init(query: Activity.query()),
                               timeLineViewModel: .init(query: Post.query()))
    }
}
