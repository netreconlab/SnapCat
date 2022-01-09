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

    @Environment(\.tintColor) private var tintColor
    @EnvironmentObject var userStatus: UserStatus
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        VStack {
            Spacer()
            if !User.apple.isLinked {
                SignInWithAppleButton(.continue,
                                      onRequest: { (request) in
                                        request.requestedScopes = [.fullName, .email]
                                      },
                                      onCompletion: { (result) in

                                        switch result {
                                        case .success(let authorization):
                                            Task {
                                                await viewModel.linkWithApple(authorization: authorization)
                                            }
                                        case .failure(let error):
                                            viewModel.linkError = SnapCatError(message: error.localizedDescription)
                                        }
                                      })
                    .frame(width: 300, height: 50)
                    .cornerRadius(15)
            }
            Button(action: {
                Task {
                    await viewModel.logout()
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
            Spacer()
            if let link = URL(string: "https://www.cs.uky.edu/~baker/"),
               let image = UIImage(named: "netrecon") {
                HStack {
                    Spacer()
                    Link(destination: link, label: {
                        VStack {
                            Text("Developed by the")
                                .foregroundColor(Color(tintColor))
                            Text("University of Kentucky")
                                .foregroundColor(Color(tintColor))
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 50, alignment: .center)
                        }
                    })
                    Spacer()
                }
            }
        }.onReceive(viewModel.$isLoggedOut, perform: { value in
            if self.userStatus.isLoggedOut != value {
                self.userStatus.check()
            }
        })
        .navigationBarTitle("Settings")
        .navigationBarHidden(false)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserStatus(isLoggedOut: false))
    }
}
