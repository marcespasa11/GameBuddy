//
//  ProfileView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 30/7/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var profileViewModel: ProfileViewModel
    @State private var showingImagePicker = false
    @State private var newName: String = ""
    @State private var newPassword: String = ""

    init() {
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(userSession: UserSession()))
    }

    var body: some View {
        VStack {
            if let user = userSession.currentUser {

                // Imagen de perfil
                if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                    }
                    .onTapGesture {
                        profileViewModel.showImagePicker = true
                    }
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            profileViewModel.showImagePicker = true
                        }
                }

                TextField("New name", text: $newName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        self.newName = user.name // Cargar el nombre actual del usuario
                    }

                SecureField("New password", text: $newPassword)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    profileViewModel.updateProfile(newName: newName, newPassword: newPassword)
                }) {
                    Text("Save changes")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                // Mensaje de confirmación
                if !profileViewModel.alertMessage.isEmpty {
                    Text(profileViewModel.alertMessage)
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.top, 10)
                }

                Button(action: {
                    profileViewModel.signOut()
                }) {
                    Text("Log out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.red)
                        .cornerRadius(15.0)
                }.padding()

                Button(action: profileViewModel.deleteUser) {
                    Text("Delete user")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            } else {
                Text("Cargando perfil...")
                    .font(.title)
                    .padding()
            }
        }
        .navigationTitle("Perfil")
        .onAppear {
            profileViewModel.userSession = userSession
        }
        .sheet(isPresented: $profileViewModel.showImagePicker) {
            ImagePicker(image: $profileViewModel.selectedImage)
        }
        .alert(isPresented: $profileViewModel.showAlert) {
            Alert(title: Text("Información"), message: Text(profileViewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
