//
//  GameBuddyApp.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 10/7/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    //Auth.auth().useEmulator(withHost: "localhost", port: 9099)
    
    return true
  }
}

@main
struct GameBuddyApp: App {
    @StateObject private var appState = AppState()
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

