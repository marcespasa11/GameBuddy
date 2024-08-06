//
//  RegisterView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 24/7/24.
//

import SwiftUI
/*
struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @State private var isShowingAlert = false
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Name", text: $viewModel.user.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Email", text: $viewModel.user.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $viewModel.user.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    viewModel.register()
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("Error"), message: Text(viewModel.registrationError ?? "Unknown Error"), dismissButton: .default(Text("OK")))
                }
                .onChange(of: viewModel.isRegistrationSuccessful) { success in
                    if success {
                        isLoggedIn = true
                    } else {
                        isShowingAlert = true
                    }
                }
                
                NavigationLink(destination: LoginView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Register")
        }
    }
}
*/

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var registerViewModel = RegisterViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Name", text: $registerViewModel.name)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                TextField("Correo electrónico", text: $registerViewModel.email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                SecureField("Contraseña", text: $registerViewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                SecureField("Confirmar Contraseña", text: $registerViewModel.confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                Button(action: {
                    registerViewModel.register(userSession: userSession)
                }) {
                    Text("Registrarse")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.green)
                        .cornerRadius(15.0)
                }

                if let errorMessage = registerViewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
    }
}





extension Optional where Wrapped == String {
    var bound: String {
        self ?? ""
    }
}
