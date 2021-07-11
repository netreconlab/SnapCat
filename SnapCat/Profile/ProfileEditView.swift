//
//  ProfileEditView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/10/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var isShowAlert = false
    @State var isPasswordResetSuccess = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Username", text: $viewModel.username)
                    TextField("Email", text: $viewModel.email)
                    TextField("Name", text: $viewModel.name)
                    TextField("Bio", text: $viewModel.bio)
                    SecureField("Link", text: $viewModel.link)
                }

                Section {
                    Button(action: {
                        viewModel.resetPassword { result in
                            if case .success = result {
                                self.isPasswordResetSuccess = true
                            }
                            self.isShowAlert = true
                        }
                    }, label: {
                        Text("Reset Password")
                    })
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(Text("Edit Profile"))
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                viewModel.saveUpdates { result in
                    if case .failure(let error) = result {
                        if error.message.contains("No new changes") {
                            self.presentationMode.wrappedValue.dismiss()
                            return
                        }
                    }
                    self.isShowAlert = true
                }
            }, label: {
                Text("Done")
            }))
            .alert(isPresented: $isShowAlert, content: {
                if let error = viewModel.error {
                    return Alert(title: Text("Error"),
                                 message: Text(error.message),
                                 dismissButton: .default(Text("Ok"), action: {
                                 })
                    )
                } else if self.isPasswordResetSuccess {
                    return Alert(title: Text("Password Reset"),
                                 message: Text("Please check your email for directions on how to reset your password"),
                                 dismissButton: .default(Text("Ok"), action: {
                                    self.presentationMode.wrappedValue.dismiss()
                                 })
                    )
                } else {
                    return Alert(title: Text("Updates Saved"),
                                 message: Text("All changes saved!"),
                                 dismissButton: .default(Text("Ok"), action: {
                                    self.presentationMode.wrappedValue.dismiss()
                                 })
                    )
                }

            })
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(viewModel: ProfileViewModel(user: nil))
    }
}
