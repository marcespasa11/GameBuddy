//
//  Location.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 23/7/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import CoreLocation

struct Location: Codable {
    //Gastar location predefinida swift?? --> CLLocation
    @DocumentID var matchId: String?
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from geoPoint: GeoPoint) {
        self.latitude = geoPoint.latitude
        self.longitude = geoPoint.longitude
    }
    
    func toGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
}

