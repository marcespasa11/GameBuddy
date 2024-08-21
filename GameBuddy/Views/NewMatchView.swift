//
//  NewMatchView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//

import SwiftUI
import MapKit

struct NewMatchView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel: NewMatchViewModel

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.4699, longitude: -0.3763), // Coordenadas iniciales para Valencia, España
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?

    init() {
        _viewModel = StateObject(wrappedValue: NewMatchViewModel(userSession: UserSession()))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mapa en la parte superior
                    ZStack {
                        MapViewRepresentable(region: $region, selectedLocation: $selectedLocation)
                            .frame(height: 300)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack {
                                    Button(action: {
                                        zoomIn()
                                    }) {
                                        Image(systemName: "plus.magnifyingglass")
                                            .padding(10)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(radius: 5)
                                    }
                                    .padding(.bottom, 8)
                                    
                                    Button(action: {
                                        zoomOut()
                                    }) {
                                        Image(systemName: "minus.magnifyingglass")
                                            .padding(10)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(radius: 5)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Tipo de Partido
                        Text("Match Type")
                            .font(.headline)
                        Picker("Select Match Type", selection: $viewModel.selectedMatchType) {
                            ForEach(MatchType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        // Detalles del Partido
                        Text("Details")
                            .font(.headline)
                        VStack(spacing: 16) {
                            DatePicker("Select Date and Time", selection: $viewModel.matchDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()

                            Stepper("Max Players: \(viewModel.maxPlayers)", value: $viewModel.maxPlayers, in: 2...20)

                            TextField("Description", text: $viewModel.matchDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.horizontal)

                    // Botón de Crear Partido
                    Button(action: {
                        if let selectedLocation = selectedLocation {
                            viewModel.matchLocation = IdentifiableLocation(coordinate: selectedLocation)
                            viewModel.createMatch()
                        }
                    }) {
                        Text("Create Match")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isFormValid && selectedLocation != nil ? Color.blue : Color.gray)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(!viewModel.isFormValid || selectedLocation == nil)
                }
                .padding(.top)
            }
            .navigationTitle("New Match")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Match Creation"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func zoomIn() {
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
    }

    private func zoomOut() {
        region.span.latitudeDelta *= 2.0
        region.span.longitudeDelta *= 2.0
    }
}


enum MatchType: String, CaseIterable {
    case soccer = "Soccer ⚽️"
    case handball = "Handball 🤾🏽‍♀️"
    case basketball = "Basketball 🏀"
}
