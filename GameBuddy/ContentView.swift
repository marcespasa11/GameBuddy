//
//  ContentView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 10/7/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            NavigationView {
                //ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }

            NavigationView {
                //NewMatchView()
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("New Match")
            }
        }
    }
}

#Preview {
    ContentView()
}
