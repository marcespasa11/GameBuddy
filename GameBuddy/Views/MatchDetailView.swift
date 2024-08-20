//
//  MatchDetailView.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 27/7/24.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MatchDetailView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel: MatchDetailViewModel
    @State private var isShowingEditView = false

    init(match: Match, userSession: UserSession) {
        _viewModel = StateObject(wrappedValue: MatchDetailViewModel(match: match, userSession: userSession))
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Añadir un logo en la parte superior
                        HStack {
                            Spacer()
                            Image(systemName: "sportscourt")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .padding(.bottom, 20)
                            Spacer()
                        }
                        
                        Text("Match Details")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)
                        
                        Group {
                            Text("\(viewModel.match.type)")
                                .font(.title2)
                                .padding(.bottom, 5)
                            
                            Text("\(viewModel.address)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)

                            Text("\(viewModel.match.date, style: .date) \(viewModel.match.date, style: .time)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)

                            Text("\(Image(systemName: "person.fill")): \(viewModel.match.players)/\(viewModel.match.maxPlayers)")
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
                        
                        // Lista de correos con el organizador marcado
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
                                    .id(comment.id) // Añadir ID para la navegación con ScrollViewProxy
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        }
                        .frame(height: 200) // Fija la altura del ScrollView para comentarios

                        Divider().padding(.vertical)

                        HStack {
                            TextField("Add a comment...", text: $viewModel.newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                viewModel.addComment()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    scrollToBottom(proxy: proxy) // Desplazarse al final al agregar un comentario
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
                            .frame(height: 100) // Añadir un espaciador para evitar que la vista sea tapada por los botones flotantes
                    }
                    .padding()
                    .navigationTitle("Match Detail")
                    .background(Color(.systemGray6)) // Fondo suave para la vista
                }
                .onChange(of: viewModel.comments.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }

            // Botones flotantes
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
                    .padding(.bottom, 16) // Añadir espacio en la parte inferior
                    .padding(.trailing, 16) // Añadir espacio en la parte derecha
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
}
