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
    @Published var alertMessage: String = ""
    private var db = Firestore.firestore()
    @Published var userSession: UserSession
    

    private var matchListener: ListenerRegistration?

    init(match: Match, userSession: UserSession) {
        self.match = match
        self.userSession = userSession
        
        if match.id == nil {
            print("Warning: Match ID is nil. Ensure match is initialized properly.")
            alertMessage = "Match ID is missing, cannot proceed."
        } else {
            self.checkIfUserJoined()
            self.listenToMatchChanges()
        }
    }

    func toggleMatchParticipation() {
        checkIfUserJoined()
        if isUserJoined {
            leaveMatch()
        } else {
            joinMatch()
        }
    }

    private func joinMatch() {
        guard let currentUserEmail = userSession.currentUser?.email else { return }

        guard match.players < match.maxPlayers else {
            alertMessage = "Match is full"
            return
        }

        if !match.emailsOfPlayers.contains(currentUserEmail) {
            match.players += 1
            match.emailsOfPlayers.append(currentUserEmail)
            isUserJoined = true
            updateMatchInFirestore()
        }
    }

    private func leaveMatch() {
        guard let currentUserEmail = userSession.currentUser?.email else { return }

        guard match.players > 0, let index = match.emailsOfPlayers.firstIndex(of: currentUserEmail) else {
            alertMessage = "You are not part of this match"
            return
        }

        match.players -= 1
        match.emailsOfPlayers.remove(at: index)
        isUserJoined = false
        updateMatchInFirestore()
    }

    private func updateMatchInFirestore() {
        guard let matchId = match.id else {
            print("Error: Match ID is nil. Cannot update match in Firestore.")
            alertMessage = "Match ID is missing. Cannot update match."
            return
        }

        do {
            try db.collection("matches").document(matchId).setData(from: match) { error in
                if let error = error {
                    print("Error updating match in Firestore: \(error)")
                    self.alertMessage = "Failed to update match in Firebase"
                } else {
                    print("Match successfully updated in Firestore")
                    self.alertMessage = "Match updated successfully"
                }
            }
        } catch {
            print("Error encoding match: \(error)")
            self.alertMessage = "Failed to encode match data"
        }
    }

    private func checkIfUserJoined() {
        guard let currentUserEmail = userSession.currentUser?.email else { return }
        isUserJoined = match.emailsOfPlayers.contains(currentUserEmail)
    }

    private func listenToMatchChanges() {
        guard let matchId = match.id else {
            print("Error: Match ID is nil. Cannot listen to changes.")
            return
        }
        
        matchListener = db.collection("matches").document(matchId).addSnapshotListener { [weak self] documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                do {
                    let updatedMatch = try document.data(as: Match.self)
                    DispatchQueue.main.async {
                        self?.match = updatedMatch
                        self?.checkIfUserJoined() // Revisa si el usuario sigue unido después de la actualización
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
