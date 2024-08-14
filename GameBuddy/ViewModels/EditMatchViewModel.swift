//
//  EditMatchViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class EditMatchViewModel: ObservableObject {
    @Published var selectedMatchType: MatchType
    @Published var matchDate: Date
    @Published var maxPlayers: Int
    @Published var matchDescription: String
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var db = Firestore.firestore()
    @Published var userSession: UserSession
    private var match: Match
    var presentationMode: Binding<PresentationMode>?

    init(match: Match, userSession: UserSession) {
        self.match = match
        self.userSession = userSession
        self.selectedMatchType = MatchType(rawValue: match.type) ?? .soccer
        self.matchDate = match.date
        self.maxPlayers = match.maxPlayers
        self.matchDescription = match.description
    }
    
    var isFormValid: Bool {
        !matchDescription.isEmpty
    }
    
    func updateMatch() {
        match.type = selectedMatchType.rawValue
        match.date = matchDate
        match.maxPlayers = maxPlayers
        match.description = matchDescription
        
        updateMatchInFirestore()
    }
    
    private func updateMatchInFirestore() {
        guard let matchId = match.id else {
            print("Error: Match ID is nil. Cannot update match in Firestore.")
            alertMessage = "Match ID is missing. Cannot update match."
            showAlert = true
            return
        }

        do {
            try db.collection("matches").document(matchId).setData(from: match) { error in
                if let error = error {
                    print("Error updating match in Firestore: \(error)")
                    self.alertMessage = "Failed to update match in Firebase"
                    self.showAlert = true
                } else {
                    print("Match successfully updated in Firestore")
                    self.alertMessage = "Match updated successfully"
                    self.showAlert = true
                    self.presentationMode?.wrappedValue.dismiss()  // Cerrar la vista y volver al Home
                }
            }
        } catch {
            print("Error encoding match: \(error)")
            self.alertMessage = "Failed to encode match data"
            self.showAlert = true
        }
    }
}
