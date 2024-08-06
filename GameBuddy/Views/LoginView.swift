//
//  LoginView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 25/7/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = LoginViewModel()
    @State private var isShowingAlert = false
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                /*
                Button(action: {
                    viewModel.login { success in
                        if success {
                            userSession.isLoggedIn = true
                            isLoggedIn = true
                            print("Login successful")
                        } else {
                            isShowingAlert = true
                        }
                    }
                }) {
                    Text("Iniciar Sesión")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                }*/
                Button(action: {
                    viewModel.login(userSession: userSession)
                }) {
                    Text("Log in")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }

                if !(viewModel.errorMessage ?? "").isEmpty {
                    Text(viewModel.errorMessage ?? "")
                        .foregroundColor(.red)
                        .padding()
                }
                
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account yet?")
                        .foregroundColor(.blue)
                        .padding()
                }
                
                NavigationLink(destination: HomeView(), isActive: $userSession.isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("GameBuddy")
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserSession())
}
