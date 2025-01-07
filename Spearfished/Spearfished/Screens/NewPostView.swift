//
//  NewPostView.swift
//  Speared
//
//  Created by bryce burton on 12/6/24.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import SwiftUI
import PhotosUI
import MapKit
import CoreLocation

struct NewPostView: View {
    @StateObject private var viewModel = NewPostViewModel()
    @StateObject private var fishSpeciesManager = FishSpeciesManager()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var caption = ""
    @State private var selectedFishSpecies = "Select Fish Species"
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var locationName: String = ""
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Image picker
                    if let image = viewModel.postImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        PhotosPicker(selection: $viewModel.imageSelection,
                                   matching: .images,
                                   photoLibrary: .shared()) {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                Text("Select Photo")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    // Fish species picker
                    Picker("Fish Species", selection: $selectedFishSpecies) {
                        Text("Select Fish Species").tag("Select Fish Species")
                        ForEach(fishSpeciesManager.species) { species in
                            Text(species.speciesName).tag(species.speciesName)
                        }
                    }
                    .pickerStyle(.menu)
                    .task {
                        do {
                            try await fishSpeciesManager.fetchFishSpecies()
                        } catch {
                            print("Error fetching fish species: \(error)")
                        }
                    }
                    
                    // Caption field
                    TextField("Add a caption...", text: $caption, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4)
                    
                    // Location search
                    TextField("Search location...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: searchText) { newValue in
                            searchLocation(query: newValue)
                        }
                    
                    if !searchResults.isEmpty && isSearching {
                        List(searchResults, id: \.self) { item in
                            Button(action: {
                                selectLocation(item)
                                isSearching = false
                                searchText = ""
                                searchResults = []
                            }) {
                                Text(item.name ?? "Unknown Location")
                            }
                        }
                        .frame(height: min(CGFloat(searchResults.count * 44), 200))
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Map
                    Map(position: $cameraPosition, interactionModes: .all) {
                        if let location = selectedLocation {
                            Marker("Selected Location", coordinate: location)
                                .tint(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                        if let userLocation = locationManager.location?.coordinate {
                            Marker("Current Location", coordinate: userLocation)
                                .tint(.blue)
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .mapStyle(.standard)
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    
                    if !locationName.isEmpty {
                        Text(locationName)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        Task {
                            guard let location = selectedLocation else { return }
                            try? await viewModel.createPost(
                                caption: caption,
                                fishType: selectedFishSpecies,
                                location: CLLocation(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                ),
                                locationName: locationName
                            )
                            dismiss()
                        }
                    }
                    .disabled(viewModel.postImage == nil || selectedFishSpecies == "Select Fish Species")
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchLocation(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            searchResults = response.mapItems
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        selectedLocation = item.placemark.coordinate
        locationName = item.name ?? ""
        cameraPosition = .region(MKCoordinateRegion(
            center: item.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
}

// ViewModel
class NewPostViewModel: ObservableObject {
    @Published var postImage: UIImage?
    @Published var imageLocation: CLLocation?
    @Published var canPost = false
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            Task {
                if let imageSelection {
                    do {
                        let data = try await imageSelection.loadTransferable(type: Data.self)
                        if let data, let image = UIImage(data: data) {
                            await MainActor.run {
                                self.postImage = image
                            }
                        }
                    } catch {
                        print("Error loading image: \(error)")
                    }
                }
            }
        }
    }
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.child("post_images/\(filename)")
        
        _ = try await ref.putDataAsync(imageData, metadata: nil)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    func createPost(caption: String, fishType: String, location: CLLocation?, locationName: String) async throws {
        guard let image = postImage else { return }
        
        do {
            let imageUrl = try await uploadImage(image)
            
            let post = Post(
                username: Auth.auth().currentUser?.email ?? "Anonymous",
                timestamp: Date(),
                imageUrl: imageUrl,
                fishType: fishType,
                description: caption,
                location: GeoPoint(
                    latitude: location?.coordinate.latitude ?? 0,
                    longitude: location?.coordinate.longitude ?? 0
                ),
                locationName: locationName
            )
            
            try await db.collection("posts").addDocument(data: post.toDictionary())
        } catch {
            throw error
        }
    }
}

// Update LocationManager extension
extension LocationManager {
    var locationManager: CLLocationManager {
        return manager // Access the private manager property
    }
}
