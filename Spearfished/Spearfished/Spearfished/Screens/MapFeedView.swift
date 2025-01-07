import SwiftUI
import MapKit

struct MapFeedView: View {
    @StateObject private var postManager: PostManager
    @State private var selectedPost: Post?
    @State private var region: MKCoordinateRegion
    @Environment(\.dismiss) var dismiss
    
    init(isMocked: Bool = false) {
        _postManager = StateObject(wrappedValue: PostManager(isMocked: isMocked))
        
        // Initialize with default region
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        ))
    }
    
    var validPosts: [Post] {
        postManager.posts.filter { post in
            post.location.latitude.isFinite && 
            post.location.longitude.isFinite &&
            abs(post.location.latitude) <= 90 &&
            abs(post.location.longitude) <= 180
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region,
                    annotationItems: validPosts) { post in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: post.location.latitude,
                        longitude: post.location.longitude
                    )) {
                        Button {
                            selectedPost = post
                        } label: {
                            Image(systemName: "fish.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                                .padding(8)
                                .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8))
                                .clipShape(Circle())
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                        .padding()
                        
                        Spacer()
                        
                        Text("Catch Locations 🎣")
                            .font(.system(size: 35, design: .monospaced))
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8).opacity(0.9))
                    
                    Spacer()
                }
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
        }
    }
}

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    AsyncImage(url: URL(string: post.imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(hue: 0.534, saturation: 0.282, brightness: 0.8))
                            .aspectRatio(4/3, contentMode: .fit)
                    }
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(post.username)
                                .font(.system(size: 20, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                            Spacer()
                            Text(post.timestamp.formatted())
                                .font(.caption)
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                        
                        Text(post.fishType)
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        
                        Text(post.description)
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        
                        if !post.locationName.isEmpty {
                            Text(post.locationName)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        }
                    }
                    .padding()
                }
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
    }
}

#Preview {
    MapFeedView()
} 
