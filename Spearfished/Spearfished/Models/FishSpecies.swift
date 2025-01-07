import Foundation
import SwiftUI

class FishSpecies: ObservableObject, Codable, Identifiable {
    let id = UUID()
    let speciesName: String
    let scientificName: String?
    let habitat: String?
    let location: String?
    let speciesIllustrationPhoto: String?
    let imageGallery: [String]?
    let population: String?
    let fishingRate: String?
    
    enum CodingKeys: String, CodingKey {
        case speciesName = "Species Name"
        case scientificName = "Scientific Name"
        case habitat = "Habitat"
        case location = "Location"
        case speciesIllustrationPhoto = "Species Illustration Photo"
        case imageGallery = "Image Gallery"
        case population = "Population"
        case fishingRate = "Fishing Rate"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        func cleanHTML(_ string: String) -> String {
            return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let rawSpeciesName = try container.decode(String.self, forKey: .speciesName)
        speciesName = cleanHTML(rawSpeciesName)
        
        if let raw = try container.decodeIfPresent(String.self, forKey: .scientificName) {
            scientificName = cleanHTML(raw)
        } else {
            scientificName = nil
        }
        
        if let raw = try container.decodeIfPresent(String.self, forKey: .habitat) {
            habitat = cleanHTML(raw)
        } else {
            habitat = nil
        }
        
        if let raw = try container.decodeIfPresent(String.self, forKey: .location) {
            location = cleanHTML(raw)
        } else {
            location = nil
        }
        
        if let photoDict = try container.decodeIfPresent([String: String].self, forKey: .speciesIllustrationPhoto),
           let photoURL = photoDict["src"] {
            speciesIllustrationPhoto = photoURL
        } else {
            speciesIllustrationPhoto = nil
        }
        
        if let imageGalleryArray = try container.decodeIfPresent([String].self, forKey: .imageGallery) {
            imageGallery = imageGalleryArray
        } else {
            imageGallery = nil
        }
        
        if let raw = try container.decodeIfPresent(String.self, forKey: .population) {
            population = cleanHTML(raw)
        } else {
            population = nil
        }
        
        if let raw = try container.decodeIfPresent(String.self, forKey: .fishingRate) {
            fishingRate = cleanHTML(raw)
        } else {
            fishingRate = nil
        }
    }
    
    init(speciesName: String, scientificName: String? = nil, habitat: String? = nil, 
         location: String? = nil, speciesIllustrationPhoto: String? = nil, imageGallery: [String]? = nil, population: String? = nil, fishingRate: String? = nil) {
        self.speciesName = speciesName
        self.scientificName = scientificName
        self.habitat = habitat
        self.location = location
        self.speciesIllustrationPhoto = speciesIllustrationPhoto
        self.imageGallery = imageGallery
        self.population = population
        self.fishingRate = fishingRate
    }
}

@MainActor
class FishSpeciesManager: ObservableObject {
    @Published var species: [FishSpecies] = []
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        
        let headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        config.httpAdditionalHeaders = headers
        
        session = URLSession(configuration: config)
    }
    
    func fetchFishSpecies() async throws {
        // For now, let's use a static list of common spearfishing species
        let commonSpecies = [
            FishSpecies(
                speciesName: "Mahi Mahi",
                scientificName: "Coryphaena hippurus",
                habitat: "Pelagic",
                location: "Tropical and subtropical waters",
                population: "Stable",
                fishingRate: "Sustainable"
            ),
            FishSpecies(
                speciesName: "Red Snapper",
                scientificName: "Lutjanus campechanus",
                habitat: "Reef",
                location: "Western Atlantic",
                population: "Rebuilding",
                fishingRate: "Managed"
            ),
            FishSpecies(
                speciesName: "Grouper",
                scientificName: "Epinephelus sp.",
                habitat: "Reef",
                location: "Tropical and subtropical waters",
                population: "Varies by species",
                fishingRate: "Managed"
            ),
            FishSpecies(
                speciesName: "Yellowtail Snapper",
                scientificName: "Ocyurus chrysurus",
                habitat: "Reef",
                location: "Western Atlantic",
                population: "Stable",
                fishingRate: "Sustainable"
            ),
            FishSpecies(
                speciesName: "Cobia",
                scientificName: "Rachycentron canadum",
                habitat: "Pelagic",
                location: "Worldwide tropical waters",
                population: "Stable",
                fishingRate: "Sustainable"
            ),
            FishSpecies(
                speciesName: "Wahoo",
                scientificName: "Acanthocybium solandri",
                habitat: "Pelagic",
                location: "Tropical and subtropical waters",
                population: "Stable",
                fishingRate: "Sustainable"
            ),
            FishSpecies(
                speciesName: "Hogfish",
                scientificName: "Lachnolaimus maximus",
                habitat: "Reef",
                location: "Western Atlantic",
                population: "Stable",
                fishingRate: "Managed"
            ),
            FishSpecies(
                speciesName: "African Pompano",
                scientificName: "Alectis ciliaris",
                habitat: "Pelagic",
                location: "Tropical waters",
                population: "Stable",
                fishingRate: "Sustainable"
            ),
            FishSpecies(
                speciesName: "Amberjack",
                scientificName: "Seriola dumerili",
                habitat: "Reef/Pelagic",
                location: "Worldwide tropical waters",
                population: "Stable",
                fishingRate: "Managed"
            ),
            FishSpecies(
                speciesName: "Barracuda",
                scientificName: "Sphyraena barracuda",
                habitat: "Reef/Pelagic",
                location: "Tropical waters",
                population: "Stable",
                fishingRate: "Sustainable"
            )
        ]
        
        await MainActor.run {
            self.species = commonSpecies
            print("Loaded \(commonSpecies.count) common spearfishing species")
        }
    }
} 
