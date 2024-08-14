//
//  NewMatchViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class NewMatchViewModel: ObservableObject {
    @Published var selectedMatchType: MatchType = .soccer
    @Published var matchDate: Date = Date()
    @Published var maxPlayers: Int = 10
    @Published var matchDescription: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var db = Firestore.firestore()
    @Published var userSession: UserSession

    init(userSession: UserSession) {
        self.userSession = userSession
    }
    
    var isFormValid: Bool {
        !matchDescription.isEmpty
    }
    
    func createMatch() {
        guard let user = userSession.currentUser else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }
        
        let match = Match(
            userId: user.email, // Usamos el email del usuario como identificador
            type: selectedMatchType.rawValue,
            location: Location(latitude: 0.0, longitude: 0.0), // Replace with real location logic
            date: matchDate,
            players: 1,
            maxPlayers: maxPlayers,
            description: matchDescription,
            emailsOfPlayers: [user.email], // Agregamos el correo del usuario como primer jugador
            comments: []
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
        // Restablece los campos del formulario a sus valores por defecto
        selectedMatchType = .soccer
        matchDate = Date()
        maxPlayers = 10
        matchDescription = ""
    }
}
