//
//  NewMatchView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//

import SwiftUI
import SwiftUI

struct NewMatchView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel: NewMatchViewModel

    init() {
        _viewModel = StateObject(wrappedValue: NewMatchViewModel(userSession: UserSession()))
    }

    var body: some View {
        NavigationView {
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
                        viewModel.createMatch()
                    }) {
                        Text("Create Match")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .navigationTitle("New Match")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Match Creation"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}


enum MatchType: String, CaseIterable {
    case soccer = "Soccer"
    case handball = "Handball"
    case basketball = "Basketball"
}

