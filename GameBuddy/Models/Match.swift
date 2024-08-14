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
    var comments: [Comment]

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case type
        case location
        case date
        case players
        case maxPlayers
        case description
        case emailsOfPlayers // Asegúrate de incluir este campo en el enum
        case comments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        type = try container.decode(String.self, forKey: .type)
        
        let geoPoint = try container.decode(GeoPoint.self, forKey: .location)
        location = Location(from: geoPoint)
        
        date = try container.decode(Date.self, forKey: .date)
        players = try container.decode(Int.self, forKey: .players)
        maxPlayers = try container.decode(Int.self, forKey: .maxPlayers)
        description = try container.decode(String.self, forKey: .description)
        emailsOfPlayers = try container.decodeIfPresent([String].self, forKey: .emailsOfPlayers) ?? [] // Decodificar emailsOfPlayers

        do {
            comments = try container.decode([Comment].self, forKey: .comments)
        } catch {
            comments = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(type, forKey: .type)
        try container.encode(location.toGeoPoint(), forKey: .location)
        try container.encode(date, forKey: .date)
        try container.encode(players, forKey: .players)
        try container.encode(maxPlayers, forKey: .maxPlayers)
        try container.encode(description, forKey: .description)
        try container.encode(emailsOfPlayers, forKey: .emailsOfPlayers) // Codificar emailsOfPlayers
        try container.encode(comments, forKey: .comments)
    }
}
