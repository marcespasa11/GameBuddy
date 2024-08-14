//
//  Match.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 23/7/24.
//
import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Match: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var type: String
    var location: Location
    var date: Date
    var players: Int
    var maxPlayers: Int
    var description: String
    var emailsOfPlayers: [String] // Lista de correos de los jugadores
}
