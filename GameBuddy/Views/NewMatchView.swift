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

                Section(header: Text("Select Location")) {
                    ZStack {
                        MapViewRepresentable(region: $region, selectedLocation: $selectedLocation)
                            .frame(height: 300)

                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack {
                                    Button(action: {
                                        if let mapView = UIApplication.shared.windows.first?.rootViewController?.view.subviews.first(where: { $0 is MKMapView }) as? MKMapView {
                                            mapView.delegate?.mapView?(mapView, regionDidChangeAnimated: true)
                                            if let coordinator = mapView.delegate as? MapViewRepresentable.Coordinator {
                                                coordinator.zoomIn(mapView: mapView)
                                            }
                                        }
                                    }) {
                                        Image(systemName: "plus.magnifyingglass")
                                            .padding()
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                    .shadow(radius: 5)
                                    .padding(.bottom, 8)

                                    Button(action: {
                                        if let mapView = UIApplication.shared.windows.first?.rootViewController?.view.subviews.first(where: { $0 is MKMapView }) as? MKMapView {
                                            mapView.delegate?.mapView?(mapView, regionDidChangeAnimated: true)
                                            if let coordinator = mapView.delegate as? MapViewRepresentable.Coordinator {
                                                coordinator.zoomOut(mapView: mapView)
                                            }
                                        }
                                    }) {
                                        Image(systemName: "minus.magnifyingglass")
                                            .padding()
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                    .shadow(radius: 5)
                                }
                                .padding()
                            }
                            .padding(.bottom, 50)
                        }
                    }
                }

                Section {
                    Button(action: {
                        if let selectedLocation = selectedLocation {
                            viewModel.matchLocation = IdentifiableLocation(coordinate: selectedLocation)
                            viewModel.createMatch()
                        }
                    }) {
                        Text("Create Match")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!viewModel.isFormValid || selectedLocation == nil)
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

