//
//  LoginViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 25/7/24.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var loginError: String?
    @Published var isLoginSuccesful = false
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "All fields are required"
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if let error = error {
                self.loginError = "failed to login: \(error.localizedDescription)"
                self.isLoginSuccesful = false
            } else {
                self.isLoginSuccesful = true
                self.loginError = nil
            }
        }
    }
}
