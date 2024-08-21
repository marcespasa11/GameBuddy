//
//  MatchDetailView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 27/7/24.
//

import SwiftUI
import MapKit
import FirebaseFirestoreSwift

struct MatchDetailView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel: MatchDetailViewModel
    @State private var isShowingEditView = false
    @State private var region: MKCoordinateRegion

    init(match: Match, userSession: UserSession) {
        _viewModel = StateObject(wrappedValue: MatchDetailViewModel(match: match, userSession: userSession))
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: match.location.latitude, longitude: match.location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Mapa en la parte superior con botones de zoom
                        ZStack {
                            Map(coordinateRegion: $region, annotationItems: [viewModel.match]) { match in
                                MapMarker(coordinate: CLLocationCoordinate2D(latitude: match.location.latitude, longitude: match.location.longitude), tint: .blue)
                            }
                            .frame(height: 300)  // Aumentar el tamaño del mapa
                            .cornerRadius(10)
                            .padding(.bottom, 20)

                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack {
                                        Button(action: {
                                            zoomIn()
                                        }) {
                                            Image(systemName: "plus.magnifyingglass")
                                                .padding(10)  // Reducir el tamaño del botón
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                        }
                                        .padding(.bottom, 8)
                                        
                                        Button(action: {
                                            zoomOut()
                                        }) {
                                            Image(systemName: "minus.magnifyingglass")
                                                .padding(10)  // Reducir el tamaño del botón
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        
                        Text("\(viewModel.match.type)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)
                        
                        Group {
                            Text("\(viewModel.address)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)

                            Text("\(viewModel.match.date, style: .date) \(viewModel.match.date, style: .time)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)

                            Text("\(Image(systemName: "person.3.fill")): \(viewModel.match.players)/\(viewModel.match.maxPlayers)")
                                .font(.headline)
                                .padding(.bottom, 5)
                        }
                        
                        Divider().padding(.vertical)

                        Text("Description:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text(viewModel.match.description)
                            .padding(.bottom, 5)
                            .foregroundColor(.secondary)

                        Divider().padding(.vertical)

                        Text("Players Joined:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(viewModel.match.emailsOfPlayers.indices, id: \.self) { index in
                            HStack {
                                Text(viewModel.match.emailsOfPlayers[index])
                                    .font(.body)
                                    .padding(.bottom, 2)
                                    .foregroundColor(.primary)
                                
                                if index == 0 {
                                    Text("Organizer")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                        .padding(.leading, 5)
                                }
                            }
                        }
                        
                        Divider().padding(.vertical)

                        Text("Comments:")
                            .font(.headline)
                            .padding(.top, 10)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(viewModel.comments) { comment in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(comment.userId)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(comment.text)
                                            .foregroundColor(.primary)
                                        Text(comment.timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.bottom, 10)
                                    .id(comment.id)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        }
                        .frame(height: 200)

                        Divider().padding(.vertical)

                        HStack {
                            TextField("Add a comment...", text: $viewModel.newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                viewModel.addComment()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    scrollToBottom(proxy: proxy)
                                }
                            }) {
                                Text("Send")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .disabled(viewModel.newCommentText.isEmpty)
                        }
                        .padding(.vertical, 10)

                        Spacer()
                            .frame(height: 100)
                    }
                    .padding()
                    .navigationTitle("Match Detail")
                    .background(Color(.systemGray6))
                }
                .onChange(of: viewModel.comments.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        if viewModel.isUserOrganizer {
                            Button(action: {
                                isShowingEditView.toggle()
                            }) {
                                Text("Edit Match")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .sheet(isPresented: $isShowingEditView) {
                                EditMatchView(match: viewModel.match)
                                    .environmentObject(userSession)
                            }
                            
                            Button(action: {
                                viewModel.deleteMatch()
                            }) {
                                Text("Delete Match")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } else {
                            Button(action: {
                                viewModel.toggleMatchParticipation()
                            }) {
                                Text(viewModel.isUserJoined ? "Leave Match" : "Join Match")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.isUserJoined ? Color.red : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .padding(.trailing, 16)
                }
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastComment = viewModel.comments.last?.id {
            withAnimation {
                proxy.scrollTo(lastComment, anchor: .bottom)
            }
        }
    }

    private func zoomIn() {
        var newRegion = region
        newRegion.span.latitudeDelta /= 2.0
        newRegion.span.longitudeDelta /= 2.0
        region = newRegion
    }

    private func zoomOut() {
        var newRegion = region
        newRegion.span.latitudeDelta *= 2.0
        newRegion.span.longitudeDelta *= 2.0
        region = newRegion
    }
}
