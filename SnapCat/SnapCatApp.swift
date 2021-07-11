//
//  SnapCatApp.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift
import os.log

@main
struct SnapCatApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            OnboardingView()
        }.onChange(of: scenePhase, perform: { _ in

        })
    }

    init() {
        ParseSwift.setupServer()

        // Clear items out of the Keychain on app first run. Used for debugging
        if UserDefaults.standard.object(forKey: Constants.firstRun) == nil {
            try? User.logout()
            // This is no longer the first run
            UserDefaults.standard.setValue(String(Constants.firstRun),
                                           forKey: Constants.firstRun)
            UserDefaults.standard.synchronize()
        }

        // Set default ACL everytime app opens
        OnboardingViewModel.setDefaultACL()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard var currentInstallation = Installation.current else {
            return
        }
        currentInstallation.setDeviceToken(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.save { _ in }
    }
}
