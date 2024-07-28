//
//  LoginView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 25/7/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isShowingAlert = false
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView{
            VStack {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    viewModel.login()
                    if viewModel.isLoginSuccesful {
                        //Lògica a seguir -> redirect user to Home
                        isLoggedIn = true
                        print("Login succesful")
                    } else {
                        isShowingAlert = true
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
                    Alert(title: Text("Error"), message: Text(viewModel.loginError ?? "Unknown error"), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account yet?")
                        .foregroundColor(.blue)
                        .padding()
                }
                NavigationLink(destination: HomeView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}

#Preview {
    LoginView()
}
