//
//  Post.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    let id: String
    let location: GeoPoint
    let imageUrl: String
    let username: String
    let timestamp: Date
    let fishType: String
    let description: String
    let locationName: String
    
    init(id: String = UUID().uuidString, username: String, timestamp: Date, imageUrl: String, 
         fishType: String, description: String, location: GeoPoint, locationName: String) {
        self.id = id
        self.username = username
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.fishType = fishType
        self.description = description
        self.location = location
        self.locationName = locationName
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "username": username,
            "timestamp": timestamp,
            "imageUrl": imageUrl,
            "fishType": fishType,
            "description": description,
            "location": location,
            "locationName": locationName
        ]
    }
}
