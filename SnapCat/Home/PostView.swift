//
//  PostView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/11/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct PostView: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var postStatus: PostStatus
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @StateObject var viewModel = PostViewModel()
    @State private var isShowingImagePicker = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                Form {
                    Section {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.isShowingImagePicker = true
                            }, label: {
                                if let image = viewModel.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 0.75 * geometry.size.width,
                                               height: 0.75 * geometry.size.width,
                                               alignment: .center)
                                        .clipShape(Rectangle())
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "camera")
                                        .resizable()
                                        .frame(width: 200, height: 200, alignment: .center)
                                        .clipShape(Rectangle())
                                        .padding()
                                }
                            })
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }

                        TextField("Caption", text: $viewModel.caption)
                        if let placeMark = viewModel.currentPlacemark,
                           let name = placeMark.name {
                            Text(name)
                        } else {
                            Text("Location: N/A")
                        }
                    }
                    Section {
                        Button(action: {
                            viewModel.requestPermission()
                        }, label: {
                            if viewModel.currentPlacemark == nil {
                                Text("Use Location")
                            } else {
                                Text("Remove Location")
                            }
                        })
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle(Text("Post"))
                .navigationBarItems(leading: Button(action: {
                    self.postStatus.isShowing = false
                }, label: {
                    Text("Cancel")
                }), trailing: Button(action: {
                    Task {
                        _ = try await viewModel.save()
                    }
                    self.postStatus.isShowing = false
                }, label: {
                    Text("Done")
                }))
                .sheet(isPresented: $isShowingImagePicker, onDismiss: {}, content: {
                    ImagePickerView(image: $viewModel.image)
                })
            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(timeLineViewModel: .init(query: Post.query()))
            .environmentObject(PostStatus(isShowing: true))
    }
}
