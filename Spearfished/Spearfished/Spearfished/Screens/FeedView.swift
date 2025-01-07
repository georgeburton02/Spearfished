//
//  FeedView.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//

import SwiftUI
import FirebaseAuth

struct FeedView: View {
    @StateObject private var postManager = PostManager()
    @State private var selectedPost: Post?
    @State private var showingNewPostView = false
    @State private var showingMapView = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        try? Auth.auth().signOut()
                        dismiss()
                    }) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.title2)
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text("Feed")
                        .font(.system(size: 35, design: .monospaced))
                        .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    
                    Spacer()
                    
                    Button(action: {
                        showingNewPostView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    }
                    .padding()
                    
                    Button(action: {
                        showingMapView = true
                    }) {
                        Image(systemName: "map.fill")
                            .font(.title2)
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    }
                    .padding()
                }
                .padding()
                .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8).opacity(0.9))
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(postManager.posts) { post in
                            Button {
                                selectedPost = post
                            } label: {
                                PostRowView(post: post)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
            .sheet(isPresented: $showingNewPostView) {
                NewPostView()
            }
            .sheet(isPresented: $showingMapView) {
                MapFeedView()
            }
        }
    }
}

struct PostRowView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: post.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            HStack {
                Text(post.username)
                    .font(.headline)
                    .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                
                Spacer()
                
                Text(post.fishType)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(post.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundStyle(.secondary)
            
            Text(post.locationName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FeedView()
}
