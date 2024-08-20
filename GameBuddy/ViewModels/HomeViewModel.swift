//
//  HomeViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 27/7/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import CoreLocation

class HomeViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var matchAddresses: [String: String] = [:] // Diccionario para almacenar las direcciones por ID de partido
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchMatches() {
        db.collection("matches").addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self?.matches = documents.compactMap { queryDocumentSnapshot in
                    do {
                        let match = try queryDocumentSnapshot.data(as: Match.self)
                        if let matchId = match.id {  // Aquí ya puedes usar match directamente
                            self?.reverseGeocodeLocation(for: matchId, latitude: match.location.latitude, longitude: match.location.longitude)
                        }
                        return match
                    } catch let DecodingError.typeMismatch(type, context) {
                        print("Type '\(type)' mismatch: \(context.debugDescription)")
                        print("codingPath: \(context.codingPath)")
                    } catch {
                        print("Error decoding document into Match: \(error)")
                    }
                    return nil
                }

                print("Fetched matches: \(self?.matches ?? [])")
            }
        }
    }
    
    func reverseGeocodeLocation(for matchId: String, latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Error during reverse geocoding: \(error)")
                self?.matchAddresses[matchId] = "Address not available"
                return
            }
            
            if let placemark = placemarks?.first {
                var addressString = ""
                if let street = placemark.thoroughfare {
                    addressString += street
                }
                if let number = placemark.subThoroughfare {
                    addressString += " \(number)"
                }
                if let city = placemark.locality {
                    addressString += ", \(city)"
                }
                if addressString.isEmpty {
                    addressString = "Address not available"
                }
                DispatchQueue.main.async {
                    self?.matchAddresses[matchId] = addressString
                }
            } else {
                self?.matchAddresses[matchId] = "Address not available"
            }
        }
    }
}
