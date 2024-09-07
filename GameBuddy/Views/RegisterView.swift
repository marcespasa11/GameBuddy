//
//  RegisterView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 24/7/24.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject var userSession: UserSession
    @State private var showingImagePicker = false

    var body: some View {
        ZStack {

            VStack(spacing: 20) {
                // Título de la pantalla
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .padding(40)

                // Imagen de perfil o botón para seleccionar
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 4)) // Borde azul alrededor de la imagen
                        .shadow(radius: 10)
                } else {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Select Profile Image")
                            .font(.headline)
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                // Campos de entrada de datos
                Group {
                    TextField("Name", text: $viewModel.name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)

                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .padding(.horizontal)

                // Mostrar mensaje de error si existe
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                // Botón de registro
                Button(action: {
                    viewModel.register(userSession: userSession)
                }) {
                    Text("Register")
                        .font(.headline)
                        .padding()
                        .frame(width: 220)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 50)

                Spacer()
            }
            .padding(.horizontal)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
        }
    }
}

