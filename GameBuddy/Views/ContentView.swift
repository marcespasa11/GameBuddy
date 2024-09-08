//
//  ContentView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 10/7/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        if userSession.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var mapViewModel = MatchMapViewModel()
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    //.environmentObject(userSession)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationView {
                MatchMapViewContainer()
                    //.environmentObject(userSession)
                    .edgesIgnoringSafeArea(.all)
                    .navigationTitle("Match Locations")
            }
            .tabItem {
                Image(systemName: "map.fill")
                Text("Map")
            }

            NavigationView {
                NewMatchView()
                //.environmentObject(userSession)
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("New Match")
            }
            
            NavigationView {
                ProfileView()
                    //.environmentObject(userSession)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
    }
}

