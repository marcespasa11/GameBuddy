//
//  RegisterView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 24/7/24.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @State private var isShowingAlert = false
    
    var body: some View {
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

//            TextField("Photo (optional)", text: $viewModel.user.photoURL.bound)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()

            Button(action: {
                viewModel.register()
                if viewModel.isRegistrationSuccessful {
                    // Redirect to Home View
                    print("Succesful Register")
                } else {
                    isShowingAlert = true
                }
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
        }
        .padding()
        .navigationTitle("Register")
    }
}

extension Optional where Wrapped == String {
    var bound: String {
        self ?? ""
    }
}
