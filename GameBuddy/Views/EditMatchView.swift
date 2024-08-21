//
//  EditMatchView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 14/8/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct EditMatchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel: EditMatchViewModel
    @State private var region: MKCoordinateRegion
    @State private var selectedLocation: CLLocationCoordinate2D?

    init(match: Match) {
        _viewModel = StateObject(wrappedValue: EditMatchViewModel(match: match, userSession: UserSession()))
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: match.location.latitude, longitude: match.location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _selectedLocation = State(initialValue: CLLocationCoordinate2D(latitude: match.location.latitude, longitude: match.location.longitude))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mapa en la parte superior con marcador en la ubicación del partido
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

                    // Botón de Guardar Cambios
                    Button(action: {
                        viewModel.presentationMode = presentationMode
                        if let selectedLocation = selectedLocation {
                            viewModel.matchLocation = IdentifiableLocation(coordinate: selectedLocation)
                        }
                        viewModel.updateMatch()
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(!viewModel.isFormValid)
                }
                .padding(.top)
            }
            .navigationTitle("Edit Match")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Match Update"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
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
