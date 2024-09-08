//
//  UserSession.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 29/7/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                // Esperar que los datos se guarden correctamente antes de llamar a fetchUserData
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.fetchUserData(userID: user.uid) { fetchedUser in
                        if let fetchedUser = fetchedUser {
                            self?.setUser(fetchedUser)
                        } else {
                            self?.currentUser = nil
                        }
                    }
                }
            } else {
                self?.currentUser = nil
            }
        }
    }

    func setUser(_ user: User) {
        self.currentUser = user
        self.isLoggedIn = true
        print("User set in UserSession: \(user.name)") 
    }

    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
    
    func fetchUserData(userID: String, completion: @escaping (User?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    let user = User(
                        email: data["email"] as? String ?? "",
                        name: data["name"] as? String ?? "Name not available",
                        photoURL: data["photoURL"] as? String
                    )
                    completion(user)
                } else {
                    completion(nil)
                }
            } else {
                print("Document does not exist: \(String(describing: error?.localizedDescription))")
                completion(nil)
            }
        }
    }
}
