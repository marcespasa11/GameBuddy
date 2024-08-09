//
//  RegisterViewModel.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 24/7/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name: String = ""
    @Published var errorMessage: String?
    @Published var selectedImage: UIImage?

    func register(userSession: UserSession) {
        guard !email.isEmpty, !name.isEmpty, !password.isEmpty, password == confirmPassword else {
            self.errorMessage = "Please complete all fields and make sure the passwords match."
            return
        }

        // Crear usuario en Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let firebaseUser = authResult?.user else {
                self?.errorMessage = "User not found"
                return
            }

            // Si hay una imagen seleccionada, súbela y luego guarda los datos del usuario en Firestore
            if let image = self?.selectedImage {
                self?.uploadProfileImage(image, userID: firebaseUser.uid) { url in
                    if let url = url {
                        self?.saveUserData(userID: firebaseUser.uid, photoURL: url.absoluteString, userSession: userSession)
                    } else {
                        self?.errorMessage = "Failed to upload profile image."
                    }
                }
            } else {
                // Si no hay imagen seleccionada, guarda los datos del usuario sin la URL de la imagen
                self?.saveUserData(userID: firebaseUser.uid, photoURL: nil, userSession: userSession)
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage, userID: String, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error fetching download URL: \(error.localizedDescription)")
                            completion(nil)
                        } else {
                            completion(url)
                        }
                    }
                }
            }
        } else {
            print("Error: Image data could not be converted.")
            completion(nil)
        }
    }

    private func saveUserData(userID: String, photoURL: String?, userSession: UserSession) {
        let db = Firestore.firestore()
        var userData: [String: Any] = [
            "name": self.name,
            "email": self.email
        ]
        if let photoURL = photoURL {
            userData["photoURL"] = photoURL
        }

        db.collection("users").document(userID).setData(userData) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error saving additional information: \(error.localizedDescription)"
            } else {
                let user = User(email: self?.email ?? "", name: self?.name ?? "", photoURL: photoURL)
                userSession.setUser(user)
            }
        }
    }
}
