//
//  EditMatchView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//

import SwiftUI

struct EditMatchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel: EditMatchViewModel

    init(match: Match, userSession: UserSession) {
        _viewModel = StateObject(wrappedValue: EditMatchViewModel(match: match, userSession: userSession))
    }

    var body: some View {
        Form {
            Section(header: Text("Match Type")) {
                Picker("Select Match Type", selection: $viewModel.selectedMatchType) {
                    ForEach(MatchType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Details")) {
                DatePicker("Select Date and Time", selection: $viewModel.matchDate, displayedComponents: [.date, .hourAndMinute])

                Stepper("Max Players: \(viewModel.maxPlayers)", value: $viewModel.maxPlayers, in: 2...20)

                TextField("Description", text: $viewModel.matchDescription)
            }
            
            Section {
                Button(action: {
                    viewModel.presentationMode = presentationMode
                    viewModel.updateMatch()
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!viewModel.isFormValid)
            }
        }
        .navigationTitle("Edit Match")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Match Update"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
