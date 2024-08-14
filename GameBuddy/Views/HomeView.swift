//
//  HomeView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 27/7/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.matches) { match in
                NavigationLink(destination: MatchDetailView(match: match, userSession: userSession)
                    .environmentObject(userSession)) {
                    VStack(alignment: .leading) {
                        Text(match.type)
                            .font(.headline)
                        Text("Location: \(match.location.latitude), \(match.location.longitude)")
                        Text("Date: \(match.date, style: .date)")
                        Text("Players: \(match.players)/\(match.maxPlayers)")
                    }
                }
            }
            //IMPLEMENTAR: New match
            //.navigationBarItems(trailing: NavigationLink("New Match", destination: MatchFormView()))
            .onAppear {
                viewModel.fetchMatches()
            }
            .navigationTitle("Home")
        }
    }
}
