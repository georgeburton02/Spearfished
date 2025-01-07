//
//  PostManager.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

class PostManager: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private var listener: ListenerRegistration?
    
    init(isMocked: Bool = false) {
        if isMocked {
            setupMockData()
        } else {
            setupFirestoreListener()
        }
    }
    
    private func setupMockData() {
        posts = [
            Post(id: UUID(),
                 location: GeoPoint(latitude: 25.7617, longitude: -80.1918),
                 imageUrl: "mock_url",
                 username: "FishHunter",
                 timestamp: Date(),
                 fishType: "Mahi Mahi",
                 description: "Caught this beautiful fish!",
                 locationName: "Miami Beach"),
            Post(id: UUID(),
                 location: GeoPoint(latitude: 25.8617, longitude: -80.1218),
                 imageUrl: "mock_url2",
                 username: "SpearMaster",
                 timestamp: Date(),
                 fishType: "Grouper",
                 description: "Great day out on the water",
                 locationName: "Key Largo")
        ]
    }
    
    private func setupFirestoreListener() {
        print("Setting up Firestore listener...")
        listener = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error listening to posts: \(error.localizedDescription)")
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                print("Received \(documents.count) documents")
                
                self?.posts = documents.compactMap { document -> Post? in
                    let data = document.data()
                    guard let location = data["location"] as? GeoPoint else {
                        print("Failed to parse location for document: \(document.documentID)")
                        return nil
                    }
                    
                    return Post(
                        id: UUID(uuidString: document.documentID) ?? UUID(),
                        location: location,
                        imageUrl: data["imageUrl"] as? String ?? "",
                        username: data["username"] as? String ?? "Anonymous",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        fishType: data["fishType"] as? String ?? "Unknown",
                        description: data["description"] as? String ?? "",
                        locationName: data["locationName"] as? String ?? ""
                    )
                }
                
                print("Parsed \(self?.posts.count ?? 0) posts")
            }
    }
    
    func uploadPost(image: UIImage, description: String, location: CLLocationCoordinate2D, locationName: String, fishType: String, username: String) async throws {
        isLoading = true
        error = nil
        
        do {
            print("Starting post upload process...")
            
            // 1. Upload image
            guard let imageData = image.jpegData(compressionQuality: 0.6) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare image"])
            }
            
            let imageRef = storage.child("posts/\(UUID().uuidString).jpg")
            print("Uploading image to Firebase Storage...")
            
            let _ = try await imageRef.putDataAsync(imageData, metadata: nil)
            let imageUrl = try await imageRef.downloadURL().absoluteString
            print("Image uploaded successfully. URL: \(imageUrl)")
            
            // 2. Create Firestore document
            let post = [
                "imageUrl": imageUrl,
                "description": description,
                "location": GeoPoint(latitude: location.latitude, longitude: location.longitude),
                "locationName": locationName,
                "username": username,
                "fishType": fishType,
                "timestamp": Timestamp(date: Date())
            ] as [String : Any]
            
            print("Creating Firestore document...")
            let docRef = try await db.collection("posts").addDocument(data: post)
            print("Post created successfully with ID: \(docRef.documentID)")
            
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            print("Error uploading post: \(error.localizedDescription)")
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    deinit {
        listener?.remove()
    }
}
