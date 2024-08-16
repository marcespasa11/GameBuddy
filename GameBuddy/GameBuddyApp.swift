//
//  GameBuddyApp.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 10/7/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    //Auth.auth().useEmulator(withHost: "localhost", port: 9099)
      if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String {
                  GMSServices.provideAPIKey(apiKey)
              }
    return true
  }
}

@main
struct GameBuddyApp: App {
    @StateObject private var userSession = UserSession()
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
        }
    }
}

