//
//  RegisterViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 24/7/24.
//
/*
import Foundation
import FirebaseAuth

class RegisterViewModel: ObservableObject {
    @Published var user = User(email:"", name: "", password: "", photoURL: nil)
    @Published var registrationError: String?
    @Published var isRegistrationSuccessful = false
    
    func register() {
        guard !user.email.isEmpty, !user.password.isEmpty, !user.name.isEmpty else {
            registrationError = "All fields are required"
            return
        }
        
        Auth.auth().createUser(withEmail: user.email, password: user.password) { result, error in
            if let error = error {
                self.registrationError = "Error registering: \(error.localizedDescription)"
                self.isRegistrationSuccessful = false
            } else {
                self.isRegistrationSuccessful = true
                self.registrationError = nil
                
                //Save name and photo
                
            }
            
        }
    }
}
*/
import Firebase
import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name: String = "" // Información adicional
    @Published var errorMessage: String?

    func register(userSession: UserSession) {
        guard !email.isEmpty, !name.isEmpty, !password.isEmpty, password == confirmPassword else {
            self.errorMessage = "Please complete all fields and make sure the passwords match."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let firebaseUser = authResult?.user else {
                self?.errorMessage = "User not found"
                return
            }

            // Guardar información adicional en Firestore
            let db = Firestore.firestore()
            db.collection("users").document(firebaseUser.uid).setData([
                "name": self?.name ?? "",
                "email": self?.email ?? "",
                // Otros campos adicionales
            ]) { error in
                if let error = error {
                    self?.errorMessage = "Error saving additional information: \(error.localizedDescription)"
                } else {
                    // Crear un usuario y actualizar el estado global
                    let user = User(email: self?.email ?? "", name: self?.name ?? "Name not available")
                    //userSession.setUser(user) // COMENTAT perque ja s'executa en el init() del UserSession
                }
            }
        }
    }
}
