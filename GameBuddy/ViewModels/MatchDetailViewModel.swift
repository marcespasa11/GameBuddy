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
    @Published var comments: [Comment] = []
    @Published var newCommentText: String = ""
    @Published var isUserJoined: Bool = false
    @Published var alertMessage: String = ""
    private var db = Firestore.firestore()
    @Published var userSession: UserSession

    private var matchListener: ListenerRegistration?
    private var commentsListener: ListenerRegistration?

    init(match: Match, userSession: UserSession) {
        self.match = match
        self.userSession = userSession
        
        if match.id == nil {
            print("Warning: Match ID is nil. Ensure match is initialized properly.")
            alertMessage = "Match ID is missing, cannot proceed."
        } else {
            self.checkIfUserJoined()
            self.listenToMatchChanges()
            self.loadComments()
        }
    }

    var isUserOrganizer: Bool {
        return match.userId == userSession.currentUser?.email
    }

    func toggleMatchParticipation() {
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

    func deleteMatch() {
        guard let matchId = match.id else {
            print("Error: Match ID is nil. Cannot delete match in Firestore.")
            alertMessage = "Match ID is missing. Cannot delete match."
            return
        }

        db.collection("matches").document(matchId).delete { error in
            if let error = error {
                print("Error deleting match: \(error)")
                self.alertMessage = "Failed to delete match."
            } else {
                print("Match successfully deleted.")
                self.alertMessage = "Match deleted successfully."
            }
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

    private func loadComments() {
        guard let matchId = match.id else { return }
        commentsListener = db.collection("comments")
            .whereField("matchId", isEqualTo: matchId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error loading comments: \(error)")
                    return
                }
                self?.comments = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Comment.self)
                } ?? []
            }
    }

    func addComment() {
        guard let user = userSession.currentUser else { return }
        guard let matchId = match.id else { return }
        let newComment = Comment(userId: user.email, matchId: matchId, text: newCommentText, timestamp: Date())

        do {
            _ = try db.collection("comments").addDocument(from: newComment)
            // Actualizar comentarios localmente para que se reflejen de inmediato
            comments.append(newComment)
            newCommentText = ""
        } catch {
            print("Error adding comment: \(error)")
        }
    }

    deinit {
        matchListener?.remove()
        commentsListener?.remove()
    }
}
