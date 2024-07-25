//
//  Match.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 23/7/24.
//

import Foundation

struct Match{
    var id: String
    var type: TypeOfMatch
    var location: Location
    var date: Date
    var players: Int
    var maxPlayers: Int
    var description: String
    var comments: [Comment]
}
