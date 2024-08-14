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
    @State private var selectedSport: String = "All"

    var body: some View {
        NavigationView {
            VStack(spacing: 8) { // Reducir el espacio entre elementos dentro del VStack
                // Filtro de deportes
                Picker("Select Sport", selection: $selectedSport) {
                    Text("All").tag("All")
                    Text("Handball").tag("Handball")
                    Text("Soccer").tag("Soccer")
                    Text("Basketball").tag("Basketball")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 4) // Reducir padding superior

                // Contenido principal
                if filteredMatches.isEmpty {
                    VStack {
                        Spacer()

                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)

                            Text("Oops!")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text("It seems there are no matches yet.")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding()

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredMatches) { match in
                        NavigationLink(destination: MatchDetailView(match: match, userSession: userSession)
                            .environmentObject(userSession)) {
                            VStack(alignment: .leading) {
                                Text(match.type)
                                    .font(.headline)
                                Text("Location: \(match.location.latitude), \(match.location.longitude)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Date: \(match.date, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Players: \(match.players)/\(match.maxPlayers)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .onAppear {
                viewModel.fetchMatches()
            }
            .navigationTitle("Home")
        }
    }

    private var filteredMatches: [Match] {
        if selectedSport == "All" {
            return viewModel.matches
        } else {
            return viewModel.matches.filter { $0.type == selectedSport }
        }
    }
}
