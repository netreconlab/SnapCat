//
//  SettingsViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/10/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift
import AuthenticationServices

class SettingsViewModel: ObservableObject {
    @Published var loggedOut = false
    @Published var linkError: SnapCatError?

    // MARK: - Intents
    /**
     Links the user with Apple *asynchronously*.
     - parameter authorization: The encapsulation of a successful authorization performed by a controller..
    */
    func linkWithApple(authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credentials.identityToken else {
            let error = "Failed unwrapping Apple authorization credentials."
            Logger.settings.error("Apple Login Error: \(error)")
            return
        }

        User.apple.login(user: credentials.user, identityToken: identityToken) { result in
            switch result {

            case .success:

                if User.current?.email == nil {
                    User.current!.email = credentials.email
                }
                if User.current?.name == nil {
                    if let name = credentials.fullName {
                        var currentName = ""
                        if let givenName = name.givenName {
                            currentName = givenName
                        }
                        if let familyName = name.familyName {
                            if currentName != "" {
                                currentName = "\(currentName) \(familyName)"
                            } else {
                                currentName = familyName
                            }
                        }
                        User.current!.name = currentName
                    }
                }
                Logger.settings.debug("Apple Linking Success: \(User.current!, privacy: .private)")

            case .failure(let error):
                Logger.settings.error("Apple Linking Error: \(error)")
                self.linkError = SnapCatError(parseError: error)
            }
        }
    }

    func logout() {
        User.logout { result in
            switch result {

            case .success():
                self.loggedOut = true
                Logger.settings.info("User logged out")
            case .failure(let error):
                Logger.settings.error("Error logging out: \(error)")
                self.linkError = SnapCatError(parseError: error)
            }
        }
    }
}
