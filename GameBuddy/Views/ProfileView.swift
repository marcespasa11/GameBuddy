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
        VStack(spacing: 20) {
            if let user = userSession.currentUser {

                // Imagen de perfil
                if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 7)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 120, height: 120)
                            .shadow(radius: 7)
                    }
                    .onTapGesture {
                        profileViewModel.showImagePicker = true
                    }
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 120, height: 120)
                        .shadow(radius: 7)
                        .onTapGesture {
                            profileViewModel.showImagePicker = true
                        }
                }

                // Correo del usuario (no editable)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email")
                        .font(.headline)
                    Text(user.email)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .disabled(true) // Desactivar la edición
                }
                .padding(.horizontal)

                // Campos de texto para cambiar el nombre y la contraseña
                VStack(alignment: .leading, spacing: 10) {
                    TextField("New name", text: $newName)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .onAppear {
                            self.newName = user.name
                        }

                    SecureField("New password", text: $newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Botón para guardar cambios
                Button(action: {
                    profileViewModel.updateProfile(newName: newName, newPassword: newPassword)
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Save changes")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)


                Spacer()

                // Botón para cerrar sesión
                Button(action: {
                    profileViewModel.signOut()
                }) {
                    HStack {
                        Image(systemName: "arrow.backward.circle")
                        Text("Log out")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // Botón para eliminar la cuenta
                Button(action: profileViewModel.deleteUser) {
                    HStack {
                        Image(systemName: "trash.circle")
                        Text("Delete user")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
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
        .padding()
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}
