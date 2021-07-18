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
    @ObservedObject var timeLineViewModel: QueryImageViewModel<Post>
    @ObservedObject var viewModel = PostViewModel()
    @State private var isShowingImagePicker = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
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
                                    .frame(width: 200, height: 200, alignment: .center)
                                    .clipShape(Rectangle())
                                    .padding()
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
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                viewModel.save { result in
                    if case .success(let post) = result {
                        timeLineViewModel.results.insert(post, at: 0)
                    }
                }
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Done")
            }))
            .sheet(isPresented: $isShowingImagePicker, onDismiss: {}, content: {
                ImagePickerView(image: $viewModel.image)
            })
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(timeLineViewModel: .init(query: Post.query()))
    }
}
