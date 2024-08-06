//
//  LoginViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 25/7/24.
//

import Foundation
import FirebaseAuth
import Firebase

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?

    func login(userSession: UserSession) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let firebaseUser = authResult?.user else {
                self?.errorMessage = "User not found"
                return
            }

            // Recuperar datos adicionales del usuario desde Firestore
            userSession.fetchUserData(userID: firebaseUser.uid) { user in
                if let user = user {
                    userSession.setUser(user) // Actualizar currentUser e isLoggedIn en UserSession
                } else {
                    self?.errorMessage = "No se pudo obtener la información del usuario."
                }
            }
        }
    }
}
/*
func login(completion: @escaping (Bool) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error = error {
            self.errorMessage = error.localizedDescription
            completion(false)
        } else {
            // Assuming authentication is successful
            self.userSession.currentUser = User(email: self.email, name: "User Name", password: self.password)
            self.userSession.isLoggedIn = true
            completion(true)
        }
    }
}*/
