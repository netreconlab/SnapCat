//
//  OnboardingView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift
import AuthenticationServices

struct OnboardingView: View {
    @Environment(\.tintColor) private var tintColor
    @EnvironmentObject var userStatus: UserStatus
    @StateObject private var viewModel = OnboardingViewModel()
    @State var gradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1))]),
                                         startPoint: .top,
                                         endPoint: .bottom)
    @State private var usersname = ""
    @State private var password = ""
    @State var name: String = ""
    @State private var signupLoginSegmentValue = 0
    @State private var presentMainScreen = false

    var body: some View {

        VStack {

            Text("SnapCat")
                .font(Font.custom("noteworthy-bold", size: 40))
                .foregroundColor(.white)
                .padding([.top], 40)

            Image("Snapcat")
                .resizable()
                .frame(width: 250, height: 250, alignment: .center)
                .clipShape(Circle())
                .overlay(Circle().stroke(gradient, lineWidth: 4))
                .shadow(radius: 10)
                .padding()

            Picker(selection: $signupLoginSegmentValue, label: Text("Login Picker"), content: {
                Text("Login").tag(0)
                Text("Sign Up").tag(1)
            })
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.white)
            .cornerRadius(20.0)
            .padding()

            VStack(alignment: .leading) {
                TextField("Username", text: $usersname)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)

                if signupLoginSegmentValue == 1 {
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20.0)
                        .shadow(radius: 10.0, x: 20, y: 10)
                }
            }.padding([.leading, .trailing], 27.5)

            Button(action: {
                if signupLoginSegmentValue == 1 {
                    Task {
                        await viewModel.signup(username: usersname,
                                               password: password,
                                               name: name)
                    }
                } else {
                    Task {
                        await viewModel.login(username: usersname, password: password)
                    }
                }

            }, label: {

                if signupLoginSegmentValue == 1 {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                } else {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                }
            })
            .background(Color(.green))
            .cornerRadius(15)

            Button(action: {
                Task {
                    await viewModel.loginAnonymously()
                }

            }, label: {

                if signupLoginSegmentValue == 1 {
                    Text("Login Anonymously")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                } else {
                    Text("Login Anonymously")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                }
            })
            .background(Color(#colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1)))
            .cornerRadius(15)

            SignInWithAppleButton(.signIn,
                                  onRequest: { (request) in
                                    request.requestedScopes = [.fullName, .email]
                                  },
                                  onCompletion: { (result) in

                                    switch result {
                                    case .success(let authorization):
                                        Task {
                                            await viewModel.loginWithApple(authorization: authorization)
                                        }
                                    case .failure(let error):
                                        viewModel.loginError = SnapCatError(message: error.localizedDescription)
                                    }
                                  })
                .frame(width: 300, height: 50)
                .cornerRadius(15)

            // If error occurs show it on the screen
            if let error = viewModel.loginError {
                Text("Error: \(error.message)")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .onReceive(viewModel.$isLoggedOut, perform: { value in
            if self.userStatus.isLoggedOut != value {
                self.userStatus.check()
            }
        })
        .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1)), Color(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1))]),
                                   startPoint: .top,
                                   endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
        .signInWithAppleButtonStyle(.black)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(UserStatus(isLoggedOut: false))
    }
}
