//
//  MatchDetailView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 27/7/24.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MatchDetailView: View {
    @StateObject private var viewModel: MatchDetailViewModel

    init(match: Match) {
        _viewModel = StateObject(wrappedValue: MatchDetailViewModel(match: match))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Type: \(viewModel.match.type)")
                .font(.title)
                .padding(.bottom, 5)
            Text("Location: \(viewModel.match.location.latitude), \(viewModel.match.location.longitude)")
                .padding(.bottom, 5)
            Text("Date: \(viewModel.match.date, style: .date) \(viewModel.match.date, style: .time)")
                .padding(.bottom, 5)
            Text("Players: \(viewModel.match.players)/\(viewModel.match.maxPlayers)")
                .padding(.bottom, 5)
            Text("Description: \(viewModel.match.description)")
                .padding(.bottom, 5)
            Text("Comments:")
                .font(.headline)
                .padding(.bottom, 5)
            ForEach(viewModel.match.comments) { comment in
                Text("\(comment.text) by User: \(comment.userId)")
                    .padding(.bottom, 5)
            }
            Spacer()

            Button(action: {
                viewModel.toggleMatchParticipation()
            }) {
                Text(viewModel.isUserJoined ? "Leave Match" : "Join Match")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isUserJoined ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Match Detail")
    }
}
