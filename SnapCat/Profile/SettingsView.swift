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
    @StateObject var viewModel = SettingsViewModel()
    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    @Environment(\.presentationMode) var presentationMode
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
