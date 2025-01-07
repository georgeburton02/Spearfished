import SwiftUI

struct FishDetailView: View {
    let fishSpecies: String
    @StateObject private var fishSpeciesManager = FishSpeciesManager()
    @State private var selectedFish: FishSpecies?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        ProgressView("Loading fish information...")
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    } else if let error = errorMessage {
                        VStack {
                            Text("Error loading data")
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                            Text(error)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(.red)
                            Button("Retry") {
                                Task {
                                    await fetchFishData()
                                }
                            }
                            .padding()
                            .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8))
                            .cornerRadius(8)
                        }
                    } else if let fish = selectedFish {
                        // Main species photo
                        if let photoURL = fish.speciesIllustrationPhoto {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        // Image gallery
                        if let gallery = fish.imageGallery, !gallery.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(gallery, id: \.self) { urlString in
                                        AsyncImage(url: URL(string: urlString)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Text(fish.speciesName)
                            .font(.system(size: 24, design: .monospaced))
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        
                        if let scientificName = fish.scientificName {
                            Text("Scientific Name: \(scientificName)")
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                        
                        if let habitat = fish.habitat {
                            Text("Habitat: \(habitat)")
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                        
                        if let location = fish.location {
                            Text("Location: \(location)")
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                        
                        if let population = fish.population {
                            Text("Population: \(population)")
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                        
                        if let fishingRate = fish.fishingRate {
                            Text("Fishing Rate: \(fishingRate)")
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                    } else {
                        Text("No information found for \(fishSpecies)")
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    }
                }
                .padding()
            }
            .background(Color(hue: 0.492, saturation: 0.18, brightness: 0.921))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    }
                }
            }
        }
        .task {
            await fetchFishData()
        }
    }
    
    private func fetchFishData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await fishSpeciesManager.fetchFishSpecies()
            // Print available species names for debugging
            print("Available species: \(fishSpeciesManager.species.map { $0.speciesName })")
            print("Looking for species: \(fishSpecies)")
            
            // Try to find a match using more flexible matching
            selectedFish = fishSpeciesManager.species.first { species in
                let normalizedSpecies = species.speciesName.lowercased().trimmingCharacters(in: .whitespaces)
                let normalizedSearch = fishSpecies.lowercased().trimmingCharacters(in: .whitespaces)
                
                // Check for exact match or partial match
                return normalizedSpecies == normalizedSearch ||
                       normalizedSpecies.contains(normalizedSearch) ||
                       normalizedSearch.contains(normalizedSpecies)
            }
            
            if selectedFish == nil {
                print("No match found for: \(fishSpecies)")
            }
        } catch {
            print("Error fetching fish species: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 