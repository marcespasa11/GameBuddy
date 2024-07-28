//
//  RegisterViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 24/7/24.
//

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
