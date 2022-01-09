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
            MainView()
        }.onChange(of: scenePhase, perform: { _ in

        })
    }

    init() {
        ParseSwift.setupServer()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard var currentInstallation = Installation.current else {
            return
        }
        currentInstallation.setDeviceToken(deviceToken)
        currentInstallation.save { _ in }
    }
}
