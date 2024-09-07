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
    @State private var isAscending: Bool = true

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                
                Picker("Select Sport", selection: $selectedSport) {
                    Text("All").tag("All")
                    Text("Handball").tag("Handball 🤾🏽‍♀️")
                    Text("Soccer").tag("Soccer ⚽️")
                    Text("Basketball").tag("Basketball 🏀")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 4)

            
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
                                Text("\(match.address ?? "Address not available")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(match.date, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(Image(systemName: "person.3.fill")): \(match.players)/\(match.maxPlayers)")
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

            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isAscending.toggle()
                        if isAscending {
                            viewModel.sortMatchesAscending()
                        } else {
                            viewModel.sortMatchesDescending()
                        }
                    }) {
                        Image(systemName: isAscending ? "arrow.up.arrow.down.circle" : "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .padding()
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
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
