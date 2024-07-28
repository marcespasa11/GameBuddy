//
//  MatchDetailViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 27/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MatchDetailViewModel: ObservableObject {
    @Published var match: Match
    @Published var isUserJoined: Bool = false
    private var db = Firestore.firestore()
    private var userId: String = "currentUserId" // Debe ser el ID del usuario autenticado actual
    private var matchListener: ListenerRegistration?

    init(match: Match) {
        self.match = match
        self.checkIfUserJoined()
        self.listenToMatchChanges()
    }

    func toggleMatchParticipation() {
        if isUserJoined {
            leaveMatch()
        } else {
            joinMatch()
        }
    }

    private func joinMatch() {
        if match.players < match.maxPlayers {
            match.players += 1
            isUserJoined = true
            updateMatchInFirestore()
        } else {
            print("Match is full")
        }
    }

    private func leaveMatch() {
        if match.players > 0 {
            match.players -= 1
            isUserJoined = false
            updateMatchInFirestore()
        } else {
            print("No players to remove")
        }
    }

    private func updateMatchInFirestore() {
        guard let matchId = match.id else { return }

        do {
            try db.collection("matches").document(matchId).setData(from: match)
        } catch {
            print("Error updating match in Firestore: \(error)")
        }
    }

    private func checkIfUserJoined() {
        //Verify if user has already joined the match
        
        isUserJoined = false
    }

    private func listenToMatchChanges() {
        guard let matchId = match.id else { return }
        
        matchListener = db.collection("matches").document(matchId).addSnapshotListener { [weak self] documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                do {
                    self?.match = try document.data(as: Match.self)
                    self?.checkIfUserJoined()
                } catch {
                    print("Error decoding document into Match: \(error)")
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    deinit {
        matchListener?.remove()
    }
}
