//
//  NewMatchViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class NewMatchViewModel: ObservableObject {
    @Published var selectedMatchType: MatchType = .soccer
    @Published var matchDate: Date = Date()
    @Published var maxPlayers: Int = 10
    @Published var matchDescription: String = ""
    @Published var matchLocation: IdentifiableLocation? // Cambiado a IdentifiableLocation
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var db = Firestore.firestore()
    @Published var userSession: UserSession

    init(userSession: UserSession) {
        self.userSession = userSession
    }
    
    var isFormValid: Bool {
        !matchDescription.isEmpty //&& matchLocation != nil
    }
    
    func createMatch() {
        guard let user = userSession.currentUser else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }
        
        guard let matchLocation = matchLocation else {
            alertMessage = "Location is not selected."
            showAlert = true
            return
        }

        let match = Match(
            userId: user.email,
            type: selectedMatchType.rawValue,
            location: Location(latitude: matchLocation.coordinate.latitude, longitude: matchLocation.coordinate.longitude), // Acceder a las coordenadas desde `coordinate`
            date: matchDate,
            players: 1,
            maxPlayers: maxPlayers,
            description: matchDescription,
            emailsOfPlayers: [user.email]
        )
        
        saveMatchToFirestore(match)
    }
    
    private func saveMatchToFirestore(_ match: Match) {
        do {
            _ = try db.collection("matches").addDocument(from: match) { error in
                if let error = error {
                    self.alertMessage = "Error creating match: \(error.localizedDescription)"
                    self.showAlert = true
                } else {
                    self.alertMessage = "Match created successfully!"
                    self.showAlert = true
                    self.resetForm()
                }
            }
        } catch {
            self.alertMessage = "Error encoding match: \(error.localizedDescription)"
            self.showAlert = true
        }
    }
    
    private func resetForm() {
        selectedMatchType = .soccer
        matchDate = Date()
        maxPlayers = 10
        matchDescription = ""
        matchLocation = nil
    }
}
