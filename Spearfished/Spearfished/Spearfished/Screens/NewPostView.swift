import SwiftUI
import PhotosUI
import CoreLocation

struct NewPostView: View {
    @StateObject private var postManager: PostManager
    @StateObject private var locationManager = LocationManager()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var imageLocation: CLLocationCoordinate2D?
    @State private var description = ""
    @State private var locationName = ""
    @State private var fishType = ""
    @State private var username = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    
    init(isMocked: Bool = false) {
        _postManager = StateObject(wrappedValue: PostManager(isMocked: isMocked))
    }
    
    func extractLocationFromImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        if let source = CGImageSourceCreateWithData(imageData as CFData, nil),
           let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
           let gps = properties["{GPS}"] as? [String: Any] {
            
            if let latitudeRef = gps["LatitudeRef"] as? String,
               let latitude = gps["Latitude"] as? Double,
               let longitudeRef = gps["LongitudeRef"] as? String,
               let longitude = gps["Longitude"] as? Double {
                
                let lat = latitudeRef == "N" ? latitude : -latitude
                let lon = longitudeRef == "E" ? longitude : -longitude
                
                imageLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                               matching: .images) {
                        Label("Select Photo", systemImage: "photo.fill")
                            .font(.headline)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                                extractLocationFromImage(image)
                            }
                        }
                    }
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    TextField("Fish Type", text: $fishType)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    TextField("Location Name", text: $locationName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4)
                        .padding(.horizontal)
                    
                    Button {
                        Task {
                            await uploadPost()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Post")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .disabled(isLoading)
                }
                .padding(.vertical)
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    func uploadPost() async {
        guard let image = selectedImage else {
            alertMessage = "Please select an image"
            showAlert = true
            return
        }
        
        guard !username.isEmpty else {
            alertMessage = "Please enter a username"
            showAlert = true
            return
        }
        
        guard !fishType.isEmpty else {
            alertMessage = "Please enter a fish type"
            showAlert = true
            return
        }
        
        guard !locationName.isEmpty else {
            alertMessage = "Please enter a location name"
            showAlert = true
            return
        }
        
        guard let location = imageLocation ?? locationManager.location?.coordinate else {
            alertMessage = "Unable to get location"
            showAlert = true
            return
        }
        
        isLoading = true
        
        do {
            try await postManager.uploadPost(
                image: image,
                description: description,
                location: location,
                locationName: locationName,
                fishType: fishType,
                username: username
            )
            dismiss()
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    NewPostView(isMocked: true)
} 
