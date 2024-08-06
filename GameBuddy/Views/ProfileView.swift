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

    init() {
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(userSession: UserSession()))
    }

    var body: some View {
        VStack {
            if let user = userSession.currentUser {
                Text("Nombre: \(user.name)")
                    .font(.title)
                    .padding()

                Text("Correo: \(user.email)")
                    .font(.subheadline)
                    .padding()

            } else {
                Text("Cargando perfil...")
                    .font(.title)
                    .padding()
            }
            
            Button(action: {
                profileViewModel.signOut()
            }) {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.red)
                    .cornerRadius(15.0)
            }.padding()
            
            Button(action: profileViewModel.deleteUser) {
                Text("Delete Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Perfil")
        .onAppear {
            profileViewModel.userSession = userSession
        }
    }
}



/*
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var userSession: UserSession

    var body: some View {
        VStack {
            /*
            //Imatge perfil
            if let photoURL = viewModel.user?.photoURL, let url = URL(string: photoURL) {
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
                    viewModel.showImagePicker = true
                }
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        viewModel.showImagePicker = true
                    }
            }*/

            if let user = viewModel.user {
                Text("Nombre: \(user.name)")
                    .font(.title)
                    .padding()

                Text("Correo: \(user.email)")
                    .font(.subheadline)
                    .padding()

                Button(action: {
                    userSession.logout()
                }) {
                    Text("Cerrar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.red)
                        .cornerRadius(15.0)
                }
            } else {
                Text("Cargando perfil...")
                    .font(.title)
                    .padding()
            }
            /*
            TextField("Name", text: $viewModel.newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("New Password", text: $viewModel.newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: viewModel.updateProfile) {
                Text("Update Profile")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: viewModel.changePassword) {
                Text("Change Password")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: viewModel.signOut) {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: viewModel.deleteUser) {
                Text("Delete Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
             */
            Spacer()
        }.onAppear {
            // Sincroniza el ProfileViewModel con UserSession
            viewModel.objectWillChange.send()
        }
        .navigationTitle("Perfil")
        .environmentObject(userSession)
        .padding()
        /*
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.newPhoto)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Alert"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
         */
    }
}*/

