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
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.bottom, 50)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
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
            .padding()        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserSession())
}
