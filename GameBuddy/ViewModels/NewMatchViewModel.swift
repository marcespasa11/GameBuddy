//
//  NewMatchViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

class NewMatchViewModel: ObservableObject {
    @Published var selectedMatchType: MatchType = .soccer
    @Published var matchDate: Date = Date()
    @Published var maxPlayers: Int = 10
    @Published var matchDescription: String = ""
    @Published var matchLocation: IdentifiableLocation?
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
            location: Location(latitude: matchLocation.coordinate.latitude, longitude: matchLocation.coordinate.longitude),
            date: matchDate,
            players: 1,
            maxPlayers: maxPlayers,
            description: matchDescription,
            emailsOfPlayers: [user.email]
        )

        saveMatchToFirestore(match)
    }
    
    private func saveMatchToFirestore(_ match: Match) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: match.location.latitude, longitude: match.location.longitude)
            
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                if let error = error {
                    print("Error during reverse geocoding: \(error.localizedDescription)")
                    self?.alertMessage = "Failed to obtain address"
                    self?.showAlert = true
                    return
                }
                
                let placemark = placemarks?.first
                let addressString = [
                    placemark?.thoroughfare, // Calle
                    placemark?.subThoroughfare, // Número
                    placemark?.locality // Ciudad
                ].compactMap { $0 }.joined(separator: ", ")
                
                var updatedMatch = match
                updatedMatch.address = addressString // Almacenar la dirección en el partido
                
                do {
                    _ = try self?.db.collection("matches").addDocument(from: updatedMatch) { error in
                        if let error = error {
                            self?.alertMessage = "Error creating match: \(error.localizedDescription)"
                            self?.showAlert = true
                        } else {
                            self?.alertMessage = "Match created successfully!"
                            self?.showAlert = true
                            self?.resetForm()
                            NotificationCenter.default.post(name: NSNotification.Name("MatchCreated"), object: nil)
                        }
                    }
                } catch {
                    self?.alertMessage = "Error encoding match: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }

    func resetForm() {
        selectedMatchType = .soccer
        matchDate = Date()
        maxPlayers = 10
        matchDescription = ""
        matchLocation = nil
    }
}
