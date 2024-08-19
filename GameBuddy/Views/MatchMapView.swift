//
//  MatchMapView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 16/8/24.
//

import SwiftUI
import MapKit

struct MatchMapView: UIViewRepresentable {
    @ObservedObject var viewModel: MatchMapViewModel
    @Binding var region: MKCoordinateRegion
    @Binding var selectedMatch: Match?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        mapView.removeAnnotations(mapView.annotations)

        let annotations = viewModel.matches.map { match -> MatchAnnotation in
            let annotation = MatchAnnotation()
            annotation.title = match.type
            annotation.subtitle = "\(match.players)/\(match.maxPlayers) players"
            annotation.coordinate = CLLocationCoordinate2D(latitude: match.location.latitude, longitude: match.location.longitude)
            annotation.matchID = match.id // Store match ID in custom annotation
            annotation.participantsInfo = "\(match.players)/\(match.maxPlayers) players" // Guardar la información de los jugadores
            return annotation
        }

        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MatchMapView

        init(_ parent: MatchMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let matchAnnotation = annotation as? MatchAnnotation else { return nil }
            
            let identifier = "MatchAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: matchAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.pinTintColor = .blue
            } else {
                annotationView?.annotation = matchAnnotation
            }
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.text = matchAnnotation.participantsInfo
            annotationView?.detailCalloutAccessoryView = detailLabel

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let matchAnnotation = view.annotation as? MatchAnnotation,
                  let matchID = matchAnnotation.matchID else { return }
            parent.selectedMatch = parent.viewModel.matches.first { $0.id == matchID }
        }
    }
}


struct MatchMapViewContainer: View {
    @StateObject private var mapViewModel = MatchMapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.4699, longitude: -0.3763), // Coordenadas iniciales para Valencia, España
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedMatch: Match?

    var body: some View {
        ZStack {
            MatchMapView(viewModel: mapViewModel, region: $region, selectedMatch: $selectedMatch)
                .edgesIgnoringSafeArea(.all)
            
            if let selectedMatch = selectedMatch {
                VStack {
                    Spacer()
                    NavigationLink(destination: MatchDetailView(match: selectedMatch, userSession: UserSession())) {
                        Text("Go to Match")
                            .bold()
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 70)
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            zoomIn()
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .shadow(radius: 5)
                        .padding(.bottom, 8)
                        
                        Button(action: {
                            zoomOut()
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
                .padding(.bottom, 70)
            }
        }
    }

    private func zoomIn() {
        var newRegion = region
        newRegion.span.latitudeDelta /= 2.0
        newRegion.span.longitudeDelta /= 2.0
        newRegion.center = region.center
        region = newRegion
    }

    private func zoomOut() {
        var newRegion = region
        newRegion.span.latitudeDelta *= 2.0
        newRegion.span.longitudeDelta *= 2.0
        newRegion.center = region.center
        region = newRegion
    }
}

class MatchAnnotation: MKPointAnnotation {
    var matchID: String?
    var participantsInfo: String? // Nueva propiedad para la información de los participantes
}

