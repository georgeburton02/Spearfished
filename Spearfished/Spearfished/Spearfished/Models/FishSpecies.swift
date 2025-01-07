import Foundation
import SwiftUI

class FishSpecies: ObservableObject, Codable, Identifiable {
    let id = UUID()
    @Published var speciesName: String
    @Published var scientificName: String?
    @Published var habitat: String?
    @Published var location: String?
    @Published var population: String?
    @Published var fishingRate: String?
    
    init(speciesName: String, scientificName: String? = nil, habitat: String? = nil, 
         location: String? = nil, population: String? = nil, fishingRate: String? = nil) {
        self.speciesName = speciesName
        self.scientificName = scientificName
        self.habitat = habitat
        self.location = location
        self.population = population
        self.fishingRate = fishingRate
    }
    
    enum CodingKeys: String, CodingKey {
        case speciesName = "Species Name"
        case scientificName = "Scientific Name"
        case habitat = "Habitat"
        case location = "Location"
        case population = "Population"
        case fishingRate = "Fishing Rate"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        speciesName = try container.decode(String.self, forKey: .speciesName)
        scientificName = try container.decodeIfPresent(String.self, forKey: .scientificName)
        habitat = try container.decodeIfPresent(String.self, forKey: .habitat)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        population = try container.decodeIfPresent(String.self, forKey: .population)
        fishingRate = try container.decodeIfPresent(String.self, forKey: .fishingRate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(speciesName, forKey: .speciesName)
        try container.encodeIfPresent(scientificName, forKey: .scientificName)
        try container.encodeIfPresent(habitat, forKey: .habitat)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(population, forKey: .population)
        try container.encodeIfPresent(fishingRate, forKey: .fishingRate)
    }
}

@MainActor
class FishSpeciesManager: ObservableObject {
    @Published var species: [FishSpecies] = []
    
    init() {
        // Initialize with empty array
    }
    
    func fetchFishSpecies() async throws {
        guard let url = URL(string: "https://www.fishwatch.gov/api/species") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Print raw response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw response: \(responseString.prefix(500))") // Print first 500 chars
        }
        
        let decoder = JSONDecoder()
        self.species = try decoder.decode([FishSpecies].self, from: data)
    }
} 
