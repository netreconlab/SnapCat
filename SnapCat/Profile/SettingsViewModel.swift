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

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var loggedOut = false
    @Published var linkError: SnapCatError?

    // MARK: - Intents
    /**
     Links the user with Apple *asynchronously*.
     - parameter authorization: The encapsulation of a successful authorization performed by a controller..
    */
    func linkWithApple(authorization: ASAuthorization) async {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credentials.identityToken else {
            let error = "Failed unwrapping Apple authorization credentials."
            Logger.settings.error("Apple Login Error: \(error)")
            return
        }

        do {
            _ = try await User.apple.login(user: credentials.user,
                                           identityToken: identityToken)
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
        } catch {
            guard let parseError = error as? ParseError else {
                Logger.settings.error("Apple Linking Error: \(error.localizedDescription)")
                return
            }
            Logger.settings.error("Apple Linking Error: \(parseError)")
            self.linkError = SnapCatError(parseError: parseError)
        }
    }

    func logout() async {
        do {
            _ = try await User.logout()
            Logger.settings.info("User logged out")
            self.loggedOut = true
        } catch {
            guard let parseError = error as? ParseError else {
                Logger.settings.error("Error logging out: \(error.localizedDescription)")
                return
            }
            Logger.settings.error("Error logging out: \(parseError.localizedDescription)")
            self.linkError = SnapCatError(parseError: parseError)
        }
    }
}
