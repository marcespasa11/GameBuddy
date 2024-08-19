//
//  IdentifiableLocation.swift
//  GameBuddy
//
//  Created by Marc Espasa González on 17/8/24.
//

import Foundation
import CoreLocation

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

