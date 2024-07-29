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
        guard match.players < match.maxPlayers else {
            print("Match is full")
            return
        }

        match.players += 1
        isUserJoined = true
        updateMatchInFirestore()
    }

    private func leaveMatch() {
        guard match.players > 0 else {
            print("No players to remove")
            return
        }

        match.players -= 1
        isUserJoined = false
        updateMatchInFirestore()
    }

    private func updateMatchInFirestore() {
        guard let matchId = match.id else { return }

        do {
            try db.collection("matches").document(matchId).setData(from: match) { error in
                if let error = error {
                    print("Error updating match in Firestore: \(error)")
                } else {
                    print("Match successfully updated in Firestore")
                }
            }
        } catch {
            print("Error encoding match: \(error)")
        }
    }

    private func checkIfUserJoined() {
        // Aquí deberías verificar si el usuario ya está unido al partido.
        // Supongamos que la lógica para verificar si el usuario está unido se basa en algún dato en Firestore.
        isUserJoined = false
    }

    private func listenToMatchChanges() {
        guard let matchId = match.id else { return }
        
        matchListener = db.collection("matches").document(matchId).addSnapshotListener { [weak self] documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                do {
                    let updatedMatch = try document.data(as: Match.self)
                    DispatchQueue.main.async {
                        self?.match = updatedMatch
                        self?.checkIfUserJoined()
                    }
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
