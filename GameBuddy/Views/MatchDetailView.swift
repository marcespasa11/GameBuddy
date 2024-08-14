//
//  MatchDetailView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 27/7/24.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MatchDetailView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel: MatchDetailViewModel

    init(match: Match, userSession: UserSession) {
        _viewModel = StateObject(wrappedValue: MatchDetailViewModel(match: match, userSession: userSession))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Añadir un logo en la parte superior
                HStack {
                    Spacer()
                    Image(systemName: "sportscourt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    Spacer()
                }
                
                Text("Match Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                Group {
                    Text("Type: \(viewModel.match.type)")
                        .font(.title2)
                        .padding(.bottom, 5)
                    
                    Text("Location: \(viewModel.match.location.latitude), \(viewModel.match.location.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)

                    Text("Date: \(viewModel.match.date, style: .date) \(viewModel.match.date, style: .time)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)

                    Text("Players: \(viewModel.match.players)/\(viewModel.match.maxPlayers)")
                        .font(.headline)
                        .padding(.bottom, 5)
                }
                
                Divider().padding(.vertical)

                Text("Description:")
                    .font(.headline)
                    .padding(.bottom, 5)
                Text(viewModel.match.description)
                    .padding(.bottom, 5)
                    .foregroundColor(.secondary)

                Divider().padding(.vertical)

                Text("Players Joined:")
                    .font(.headline)
                    .padding(.bottom, 5)
                ForEach(viewModel.match.emailsOfPlayers, id: \.self) { email in
                    Text(email)
                        .font(.body)
                        .padding(.bottom, 2)
                        .foregroundColor(.primary)
                }
                
                Divider().padding(.vertical)

                Text("Comments:")
                    .font(.headline)
                    .padding(.top, 10)
                ForEach(viewModel.match.comments) { comment in
                    VStack(alignment: .leading) {
                        Text("User: \(comment.userId)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(comment.text)
                            .padding(.bottom, 5)
                            .foregroundColor(.primary)
                    }
                }

                Spacer()

                Button(action: {
                    viewModel.toggleMatchParticipation()
                }) {
                    Text(viewModel.isUserJoined ? "Leave Match" : "Join Match")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isUserJoined ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
            }
            .padding()
            .navigationTitle("Match Detail")
            .background(Color(.systemGray6)) // Fondo suave para la vista
        }
    }
}
