//
//  OnboardingViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift
import AuthenticationServices
import os.log

class OnboardingViewModel: ObservableObject {

    @Published private(set) var isLoggedIn = false
    @Published var loginError: SnapCatError?

    init() {
        if User.current != nil {
            isLoggedIn = true
        }
    }

    // MARK: Intents
    /**
     Signs up the user *asynchronously*.

     This will also enforce that the username isn't already taken.

     - parameter username: The username the user is signing in with.
     - parameter password: The password the user is signing in with.
     - parameter name: The name the user is signing in with.
    */
    func signup(username: String, password: String, name: String) {
        var user = User()
        user.username = username
        user.password = password
        user.name = name
        user.signup { result in
            switch result {

            case .success(let user):
                Logger.onboarding.debug("Signup Successful: \(user)")
                self.completeOnboarding()

            case .failure(let error):

                Logger.onboarding.error("\(error)")
                switch error.code {
                case .usernameTaken: // Account already exists for this username.
                    self.loginError = SnapCatError(parseError: error)

                default:
                    // There was a different issue that we don't know how to handle
                    Logger.onboarding.error("""
*** Error Signing up as user for Parse Server. Are you running parse-hipaa
and is the initialization complete? Check http://localhost:1337 in your
browser. If you are still having problems check for help here:
https://github.com/netreconlab/parse-postgres#getting-started ***
""")
                    Logger.onboarding.error("Signup Error: \(error)")

                    self.loginError = SnapCatError(parseError: error)
                }
            }
        }
    }

    /**
     Logs in the user *asynchronously*.

     This will also enforce that the username isn't already taken.

     - parameter username: The username the user is logging in with.
     - parameter password: The password the user is logging in with.
    */
    func login(username: String, password: String) {

        User.login(username: username, password: password) { result in

            switch result {

            case .success(let user):
                Logger.onboarding.debug("Login Success: \(user, privacy: .private)")
                self.completeOnboarding()
            case .failure(let error):
                Logger.onboarding.error("""
*** Error logging into Parse Server. If you are still having problems
check for help here:
https://github.com/netreconlab/parse-hipaa#getting-started ***
""")
                Logger.onboarding.debug("Login Error: \(error)")
                self.loginError = SnapCatError(parseError: error)
            }
        }
    }

    /**
     Logs in the user anonymously *asynchronously*.
    */
    func loginAnonymously() {

        User.anonymous.login { result in

            switch result {

            case .success(let user):
                Logger.onboarding.debug("Anonymous Login Success: \(user, privacy: .private)")
                self.completeOnboarding()

            case .failure(let error):
                Logger.onboarding.error("""
*** Error logging into Parse Server. If you are still having
problems check for help here:
https://github.com/netreconlab/parse-hipaa#getting-started ***
""")
                Logger.onboarding.error("Anonymous Login Error: \(error)")
                self.loginError = SnapCatError(parseError: error)
            }
        }
    }

    /**
     Logs in the user with Apple *asynchronously*.
     - parameter authorization: The encapsulation of a successful authorization performed by a controller..
    */
    func loginWithApple(authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credentials.identityToken else {
            let error = "Failed unwrapping Apple authorization credentials."
            Logger.onboarding.error("Apple Login Error: \(error)")
            self.loginError = SnapCatError(message: error)
            return
        }

        User.apple.login(user: credentials.user, identityToken: identityToken) { result in
            switch result {

            case .success:

                // This is a new user
                User.current!.email = credentials.email

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
                Logger.onboarding.debug("Apple Login Success: \(User.current!, privacy: .private)")
                self.completeOnboarding()

            case .failure(let error):
                Logger.onboarding.error("Apple Login Error: \(error)")
                self.loginError = SnapCatError(parseError: error)
            }
        }
    }

    // MARK: - Helper Methods
    func completeOnboarding() {
        Self.setDefaultACL()
        saveInstallation()
        registerForNotifications()
        isLoggedIn = true
    }

    func saveInstallation() {
        // Setup installation to receive push notifications
        Installation.current?.channels = ["global"]
        Installation.current?.save { result in
            switch result {

            case .success(let installation):
                Logger.installation.debug("""
Parse Installation saved, can now receive
push notificaitons. \(installation, privacy: .private)
""")
            case .failure(let error):
                Logger.installation.debug("Error saving Parse Installation saved: \(error.localizedDescription)")
            }
        }
    }

    func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (allowed, error) in
            if allowed {
                Logger.notification.debug("User allowed notifications")
            } else {
                Logger.notification.debug("\(error.debugDescription)")
            }
        }
    }

    class func setDefaultACL() {
        if User.current != nil {
            // Set default ACL for all ParseObjects
            var defaultACL = ParseACL()
            defaultACL.publicRead = true
            defaultACL.publicWrite = false
            do {
                _ = try ParseACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
            } catch {
                guard let parseError = error as? ParseError else {
                    Logger.main.error("Error setting default ACL: \(error.localizedDescription)")
                    return
                }
                Logger.main.error("Error setting default ACL: \(parseError)")
            }
        }
    }
}
