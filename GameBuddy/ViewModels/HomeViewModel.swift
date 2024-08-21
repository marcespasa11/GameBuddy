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

class HomeViewModel: ObservableObject {
    @Published var matches: [Match] = []
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
                        return try queryDocumentSnapshot.data(as: Match.self)
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
}
