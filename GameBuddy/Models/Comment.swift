//
//  Comment.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 23/7/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Comment: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var matchId: String // Referencia al ID del match
    var text: String
    var timestamp: Date
}
