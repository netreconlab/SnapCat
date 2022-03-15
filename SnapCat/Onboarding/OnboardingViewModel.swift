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

// swiftlint:disable cyclomatic_complexity

class OnboardingViewModel: ObservableObject {

    @Published private(set) var isLoggedOut = true
    @Published var loginError: SnapCatError?

    init() {
        if User.current != nil {
            isLoggedOut = false
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
    func signup(username: String, password: String, name: String) async {
        var user = User()
        user.username = username
        user.password = password
        user.name = name
        do {
            guard try ParseSwift.isServerAvailable() else {
                Logger.onboarding.error("Server health is not \"ok\"")
                return
            }
            let user = try await user.signup()
            Logger.onboarding.debug("Signup Successful: \(user)")
            self.completeOnboarding()
        } catch {
            guard let parseError = error as? ParseError else {
                Logger.onboarding.error("\(error.localizedDescription)")
                return
            }
            Logger.onboarding.error("\(parseError)")
            switch parseError.code {
            case .usernameTaken: // Account already exists for this username.
                self.loginError = SnapCatError(parseError: parseError)

            default:
                // There was a different issue that we don't know how to handle
                Logger.onboarding.error("""
*** Error Signing up as user for Parse Server. Are you running parse-hipaa
and is the initialization complete? Check http://localhost:1337 in your
browser. If you are still having problems check for help here:
https://github.com/netreconlab/parse-postgres#getting-started ***
""")
                self.loginError = SnapCatError(parseError: parseError)
            }
        }
    }

    /**
     Logs in the user *asynchronously*.

     This will also enforce that the username isn't already taken.

     - parameter username: The username the user is logging in with.
     - parameter password: The password the user is logging in with.
    */
    func login(username: String, password: String) async {
        do {
            guard try ParseSwift.isServerAvailable() else {
                Logger.onboarding.error("Server health is not \"ok\"")
                return
            }
            let user = try await User.login(username: username, password: password)
            Logger.onboarding.debug("Login Success: \(user, privacy: .private)")
            self.completeOnboarding()
        } catch {
            guard let parseError = error as? ParseError else {
                Logger.onboarding.error("\(error.localizedDescription)")
                return
            }
            Logger.onboarding.error("""
*** Error logging into Parse Server. If you are still having problems
check for help here:
https://github.com/netreconlab/parse-hipaa#getting-started ***
""")
            Logger.onboarding.debug("Login Error: \(parseError)")
            self.loginError = SnapCatError(parseError: parseError)
        }

    }

    /**
     Logs in the user anonymously *asynchronously*.
    */
    func loginAnonymously() async {
        do {
            guard try ParseSwift.isServerAvailable() else {
                Logger.onboarding.error("Server health is not \"ok\"")
                return
            }
            let user = try await User.anonymous.login()
            Logger.onboarding.debug("Anonymous Login Success: \(user, privacy: .private)")
            self.completeOnboarding()
        } catch {
            guard let parseError = error as? ParseError else {
                Logger.onboarding.error("\(error.localizedDescription)")
                return
            }
            Logger.onboarding.error("""
*** Error logging into Parse Server. If you are still having
problems check for help here:
https://github.com/netreconlab/parse-hipaa#getting-started ***
""")
            Logger.onboarding.error("Anonymous Login Error: \(parseError)")
            self.loginError = SnapCatError(parseError: parseError)
        }
    }

    /**
     Logs in the user with Apple *asynchronously*.
     - parameter authorization: The encapsulation of a successful authorization performed by a controller..
    */
    func loginWithApple(authorization: ASAuthorization) async {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credentials.identityToken else {
            let error = "Failed unwrapping Apple authorization credentials."
            Logger.onboarding.error("Apple Login Error: \(error)")
            self.loginError = SnapCatError(message: error)
            return
        }
        do {
            guard try ParseSwift.isServerAvailable() else {
                Logger.onboarding.error("Server health is not \"ok\"")
                return
            }
            var user = try await User.apple.login(user: credentials.user, identityToken: identityToken)
            var isUpdatedUser = false
            if credentials.email != nil {
                user.email = credentials.email
                isUpdatedUser = true
            }
            if user.name == nil {
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
                    user.name = currentName
                    isUpdatedUser = true
                }
            }
            let loggedInUser: User!
            if isUpdatedUser {
                loggedInUser = try await user.save()
            } else {
                loggedInUser = user
            }
            Logger.onboarding.debug("Apple Login Success: \(loggedInUser, privacy: .private)")
            self.completeOnboarding()
        } catch {
            guard let parseError = error as? ParseError else {
                Logger.onboarding.error("\(error.localizedDescription)")
                return
            }
            Logger.onboarding.error("Apple Login Error: \(parseError)")
            self.loginError = SnapCatError(parseError: parseError)
        }
    }

    // MARK: - Helper Methods
    func completeOnboarding() {
        Self.setDefaultACL()
        saveInstallation()
        registerForNotifications()
        isLoggedOut = false
    }

    func saveInstallation() {
        // Setup installation to receive push notifications
        guard var currentInstallation = Installation.current else {
            return
        }
        currentInstallation.user = User.current
        currentInstallation.channels = ["global"] // Subscribe to particular channels
        let installation = currentInstallation
        Task {
            do {
                let installation = try await installation.save()
                Logger.installation.debug("""
Parse Installation saved, can now receive
push notificaitons. \(installation, privacy: .private)
""")
            } catch {
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
