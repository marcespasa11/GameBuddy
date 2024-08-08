//
//  ProfileViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 30/7/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var userSession: UserSession
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    init(userSession: UserSession) {
        self.userSession = userSession
    }

    func updateProfile(newName: String, newPassword: String) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = newName

        if let selectedImage = selectedImage {
            uploadPhoto(image: selectedImage) { [weak self] url in
                guard let self = self else { return }
                if let url = url {
                    changeRequest.photoURL = url
                    self.updatePhotoURLInFirestore(photoURL: url.absoluteString) { success in
                        if success {
                            self.userSession.currentUser?.photoURL = url.absoluteString
                        }
                        self.commitProfileChanges(changeRequest: changeRequest, newName: newName, newPassword: newPassword)
                    }
                } else {
                    self.commitProfileChanges(changeRequest: changeRequest, newName: newName, newPassword: newPassword)
                }
            }
        } else {
            commitProfileChanges(changeRequest: changeRequest, newName: newName, newPassword: newPassword)
        }
    }

    private func commitProfileChanges(changeRequest: UserProfileChangeRequest, newName: String, newPassword: String) {
        changeRequest.commitChanges { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.alertMessage = "Error updating profile: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                // Actualizar el nombre en Firestore
                self.updateUserNameInFirestore(newName: newName) { success in
                    if success {
                        self.userSession.currentUser?.name = newName
                        if !newPassword.isEmpty {
                            self.changePassword(newPassword: newPassword)
                        } else {
                            self.alertMessage = "Profile updated successfully!"
                            self.showAlert = true
                        }
                    } else {
                        self.alertMessage = "Error updating name in database."
                        self.showAlert = true
                    }
                }
            }
        }
    }

    private func updateUserNameInFirestore(newName: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).updateData([
            "name": newName
        ]) { error in
            if let error = error {
                print("Error updating name in Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    private func updatePhotoURLInFirestore(photoURL: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).updateData([
            "photoURL": photoURL
        ]) { error in
            if let error = error {
                print("Error updating photo URL in Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    private func changePassword(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { [weak self] error in
            if let error = error {
                self?.alertMessage = "Error changing password: \(error.localizedDescription)"
            } else {
                self?.alertMessage = "Profile and password updated successfully."
            }
            self?.showAlert = true
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

    func signOut() {
        do {
            try Auth.auth().signOut()
            userSession.logout()
        } catch {
            alertMessage = "Error logging out: \(error.localizedDescription)"
            showAlert = true
        }
    }

    func deleteUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid

        currentUser.delete { [weak self] error in
            if let error = error {
                self?.alertMessage = "Error deleting user: \(error.localizedDescription)"
                self?.showAlert = true
                return
            }

            // Eliminar los datos del usuario en Firestore
            Firestore.firestore().collection("users").document(userID).delete { error in
                if let error = error {
                    self?.alertMessage = "Error deleting data in Firestore: \(error.localizedDescription)"
                    self?.showAlert = false
                } else {
                    self?.alertMessage = "User deleted successfully."
                    self?.showAlert = true
                    self?.userSession.logout()
                }
            }
        }
    }
}
