//
//  Post.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable {
    let id: UUID
    let location: GeoPoint
    let imageUrl: String
    let username: String
    let timestamp: Date
    let fishType: String
    let description: String
    let locationName: String
    
    init(id: UUID = UUID(), location: GeoPoint, imageUrl: String, username: String, timestamp: Date, fishType: String, description: String, locationName: String) {
        self.id = id
        self.location = location
        self.imageUrl = imageUrl
        self.username = username
        self.timestamp = timestamp
        self.fishType = fishType
        self.description = description
        self.locationName = locationName
    }
}
