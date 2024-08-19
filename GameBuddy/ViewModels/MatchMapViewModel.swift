//
//  MatchMapViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 16/8/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import CoreLocation

class MatchMapViewModel: ObservableObject {
    @Published var matches: [Match] = []
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchMatches()
    }

    func fetchMatches() {
        db.collection("matches").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching matches: \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No matches found")
                return
            }

            self.matches = documents.compactMap { queryDocumentSnapshot -> Match? in
                return try? queryDocumentSnapshot.data(as: Match.self)
            }
        }
    }
}
