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
import CoreLocation

class EditMatchViewModel: ObservableObject {
    @Published var selectedMatchType: MatchType
    @Published var matchDate: Date
    @Published var maxPlayers: Int
    @Published var matchDescription: String
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var matchLocation: IdentifiableLocation?
    @Published var address: String = "Loading address..."  // Propiedad para manejar la dirección
    
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
        self.matchLocation = IdentifiableLocation(coordinate: CLLocationCoordinate2D(latitude: match.location.latitude, longitude: match.location.longitude))
        self.address = match.address ?? "Address not available"  // Cargar la dirección existente
    }
    
    var isFormValid: Bool {
        !matchDescription.isEmpty
    }

    func updateMatch() {
        match.type = selectedMatchType.rawValue
        match.date = matchDate
        match.maxPlayers = maxPlayers
        match.description = matchDescription
        
        if let matchLocation = matchLocation {
            match.location = Location(latitude: matchLocation.coordinate.latitude, longitude: matchLocation.coordinate.longitude)
            reverseGeocodeLocation(for: matchLocation.coordinate) { [weak self] updatedAddress in
                self?.match.address = updatedAddress
                self?.address = updatedAddress
                self?.updateMatchInFirestore()  // Solo actualizar Firestore después de que la dirección se haya actualizado
            }
        } else {
            updateMatchInFirestore()  // Si la ubicación no cambió, simplemente actualiza el partido
        }
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

    func reverseGeocodeLocation(for coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error during reverse geocoding: \(error.localizedDescription)")
                completion("Address not available")
                return
            }
            
            let placemark = placemarks?.first
            let addressString = [
                placemark?.thoroughfare, // Calle
                placemark?.subThoroughfare, // Número
                placemark?.locality // Ciudad
            ].compactMap { $0 }.joined(separator: ", ")
            
            let finalAddress = addressString.isEmpty ? "Address not available" : addressString
            completion(finalAddress)
        }
    }
}
