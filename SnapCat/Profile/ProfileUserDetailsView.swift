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
    @Environment(\.tintColor) private var tintColor
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var followersViewModel: QueryViewModel<Activity>
    @ObservedObject var followingsViewModel: QueryViewModel<Activity>
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @State var gradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1)), Color(#colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1))]),
                                         startPoint: .top,
                                         endPoint: .bottom)
    @State var explorerView: ExploreView?
    @State var isShowingImagePicker = false
    @State var isShowingEditProfile = false
    @State var isShowingExplorer = false

    var body: some View {
        VStack {
            NavigationLink(destination: self.explorerView
                            .navigationBarHidden(false),
                           isActive: $isShowingExplorer) {
               EmptyView()
            }
            HStack {
                Button(action: {
                    self.isShowingImagePicker = true
                }, label: {
                    if let image = viewModel.profilePicture {
                        Image(uiImage: image)
                            .resizable()
                            .frame(idealWidth: 90, maxWidth: 90, idealHeight: 90, maxHeight: 90)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .overlay(Circle().stroke(gradient, lineWidth: 3))
                            .padding()
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(idealWidth: 90, maxWidth: 90, idealHeight: 90, maxHeight: 90)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .overlay(Circle().stroke(Color(tintColor), lineWidth: 3))
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
                    let explorerViewModel = ExploreViewModel(isShowingFollowers: true,
                                                             followersViewModel: followersViewModel,
                                                             followingsViewModel: followingsViewModel)
                    self.explorerView = ExploreView(viewModel: explorerViewModel)
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
                    let explorerViewModel = ExploreViewModel(isShowingFollowers: false,
                                                             followersViewModel: followersViewModel,
                                                             followingsViewModel: followingsViewModel)
                    self.explorerView = ExploreView(viewModel: explorerViewModel)
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
                        .foregroundColor(.white)
                        .padding()
                        .cornerRadius(15)
                        .background(Color(tintColor))
                })
                .padding([.leading, .trailing], 20)
            } else {
                if viewModel.isCurrentFollowing() {
                    Button(action: {
                        Task {
                            await self.viewModel.unfollowUser()
                        }
                    }, label: {
                        Text("Unfollow")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(15)
                            .background(Color(#colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1)))
                    })
                    .padding([.leading, .trailing], 20)
                } else {
                    Button(action: {
                        Task {
                            await self.viewModel.followUser()
                        }
                    }, label: {
                        Text("Follow")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(15)
                            .background(Color(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)))
                    })
                    .padding([.leading, .trailing], 20)
                }
            }
        }.sheet(isPresented: $isShowingImagePicker, onDismiss: {}, content: {
            ImagePickerView(image: $viewModel.profilePicture)
        }).sheet(isPresented: $isShowingEditProfile, onDismiss: {}, content: {
            ProfileEditView(viewModel: viewModel)
        })
    }
}

struct ProfileUserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileUserDetailsView(viewModel: .init(user: User(), isShowingHeading: true),
                               followersViewModel: .init(query: Activity.query()),
                               followingsViewModel: .init(query: Activity.query()),
                               timeLineViewModel: .init(query: Post.query()))
    }
}
