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
    // Observa los cambios de autenticación en Firebase
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.isLoggedIn = user != nil
            if let user = user {
                self?.fetchUserData(userID: user.uid) { fetchedUser in
                    if let fetchedUser = fetchedUser {
                        self?.setUser(fetchedUser)
                    } else {
                        self?.currentUser = nil
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
                        // Mapea los datos del documento al objeto User
                        let user = User(
                            email: data["email"] as? String ?? "",
                            name: data["name"] as? String ?? ""
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
