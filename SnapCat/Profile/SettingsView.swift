//
//  SettingsView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/10/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            if !User.apple.isLinked {
                SignInWithAppleButton(.continue,
                                      onRequest: { (request) in
                                        request.requestedScopes = [.fullName, .email]
                                      },
                                      onCompletion: { (result) in

                                        switch result {
                                        case .success(let authorization):
                                            viewModel.linkWithApple(authorization: authorization)
                                        case .failure(let error):
                                            viewModel.linkError = SnapCatError(message: error.localizedDescription)
                                        }
                                      })
                    .frame(width: 300, height: 50)
                    .cornerRadius(15)
            }
            Button(action: {
                viewModel.logout { _ in
                    presentationMode.wrappedValue.dismiss()
                }
            }, label: {
                Text("Log out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
            })
            .background(Color(.red))
            .cornerRadius(15)
        }.onAppear(perform: {
            if User.current == nil {
                presentationMode.wrappedValue.dismiss()
            }
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
