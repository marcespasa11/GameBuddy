//
//  ProfileViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 30/7/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userModified: User?
    @Published var newName: String = "" // Inicializado
    @Published var newPassword: String = "" // Inicializado
    @Published var newPhoto: UIImage? // Opcional, no es necesario inicializar
    @Published var showImagePicker: Bool = false // Inicializado
    @Published var showAlert: Bool = false // Inicializado
    @Published var alertMessage: String = "" // Inicializado
    @Published var selectedImage: UIImage?
    
    var userSession: UserSession
    
    init(userSession: UserSession) {
        self.userSession = userSession
    }
    
    func updateProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = newName
        
        if let newPhoto = newPhoto {
            uploadPhoto(image: newPhoto) { url in
                if let url = url {
                    changeRequest.photoURL = url
                    self.userModified?.photoURL = url.absoluteString
                }
                self.commitProfileChanges(changeRequest: changeRequest)
            }
        } else {
            commitProfileChanges(changeRequest: changeRequest)
        }
    }
    
    private func commitProfileChanges(changeRequest: UserProfileChangeRequest) {
        changeRequest.commitChanges { error in
            if let error = error {
                self.alertMessage = "Error updating profile: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.userModified?.name = self.newName
                self.alertMessage = "Profile updated successfully."
                self.showAlert = true
            }
        }
    }
    
    private func uploadPhoto(image: UIImage, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading photo: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    storageRef.downloadURL { url, error in
                        completion(url)
                    }
                }
            }
        }
    }
    
    func changePassword() {
        guard !newPassword.isEmpty else { return }
        
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                self.alertMessage = "Error changing password: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.alertMessage = "Password updated successfully."
                self.showAlert = true
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            userSession.logout()
        } catch {
            self.alertMessage = "Error signing out: \(error.localizedDescription)"
            self.showAlert = true
        }
    }
    
    func deleteUser() {
        guard let currentUser = Auth.auth().currentUser else {
            alertMessage = "No hay usuario autenticado."
            showAlert = true
            return
        }
        
        let userID = currentUser.uid
        let db = Firestore.firestore()
        
        // Eliminar datos del usuario de Firestore
        db.collection("users").document(userID).delete { error in
            if let error = error {
                self.alertMessage = "Error al eliminar los datos del usuario: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            
            // Eliminar la cuenta de autenticación del usuario
            currentUser.delete { error in
                if let error = error {
                    self.alertMessage = "Error al eliminar la cuenta de usuario: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                // Si todo fue exitoso
                self.alertMessage = "Cuenta y datos eliminados exitosamente."
                self.showAlert = true
                self.userSession.logout() // Opcional: Limpiar la sesión
            }
        }
    }
}
