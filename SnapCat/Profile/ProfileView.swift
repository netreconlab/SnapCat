//
//  ProfileView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct ProfileView: View {
    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    @ObservedObject var timelineViewModel: QueryViewModel<Post>
    @ObservedObject var followersViewModel: QueryViewModel<Activity>
    @ObservedObject var followingsViewModel: QueryViewModel<Activity>
    @ObservedObject var viewModel: ProfileViewModel
    @State var isShowingImagePicker = false
    @State var isShowingPost = false
    @State var isShowingOptions = false
    @State var isShowingEditProfile = false

    var body: some View {
        VStack {
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
            }
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
                    Text("\(timelineViewModel.results.count)")
                        .padding(.trailing)
                    Text("Posts")
                        .padding(.trailing)
                }
                Button(action: {

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
            Divider()
            TimeLineView(viewModel: timelineViewModel)
                .navigationBarHidden(true)
                .padding()
        }.onAppear(perform: {
            followersViewModel.find()
            followingsViewModel.find()
        }).sheet(isPresented: $isShowingImagePicker, onDismiss: {}, content: {
            ImagePickerView(image: $viewModel.profilePicture)
        }).fullScreenCover(isPresented: $isShowingPost, content: {
            PostView()
        }).sheet(isPresented: $isShowingOptions, onDismiss: {}, content: {
            SettingsView()
        }).sheet(isPresented: $isShowingEditProfile, onDismiss: {}, content: {
            ProfileEditView(viewModel: viewModel)
        })
    }

    init(user: User? = nil) {
        var userProfile: User!
        if let user = user {
            userProfile = user
        } else {
            userProfile = User.current!
        }
        viewModel = ProfileViewModel(user: userProfile)
        timelineViewModel = ProfileViewModel
            .queryUserTimeLine(userProfile)
            .viewModel
        followersViewModel = ProfileViewModel
            .queryFollowers(userProfile)
            .viewModel
        followingsViewModel = ProfileViewModel
            .queryFollowings(userProfile)
            .viewModel
        timelineViewModel.find()
        followersViewModel.find()
        followingsViewModel.find()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
