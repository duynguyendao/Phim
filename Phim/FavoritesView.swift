//
//  FavoritesView.swift
//  Phim
//
//  Created on 2026
//

import SwiftUI

struct Movie: Identifiable, Codable {
    var id = UUID()
    var title: String
    var url: String
    var videoURL: String?
    var thumbnail: String?
    var addedDate: Date
}

@available(iOS 15.0, *)
struct FavoritesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var favorites: [Movie]
    @State private var showDeleteAlert = false
    @State private var movieToDelete: Movie?
    
    var body: some View {
        NavigationView {
            List {
                if favorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Chưa có phim yêu thích")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Nhấn nút ⭐ khi xem phim để lưu lại")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(favorites) { movie in
                        MovieRow(movie: movie) {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("LoadMovieURL"),
                                object: movie.url
                            )
                            dismiss()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                movieToDelete = movie
                                showDeleteAlert = true
                            } label: {
                                Label("Xóa", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yêu thích (\(favorites.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Xong") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !favorites.isEmpty {
                        Button(action: {
                            showDeleteAlert = true
                            movieToDelete = nil
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Xác nhận xóa", isPresented: $showDeleteAlert) {
                Button("Hủy", role: .cancel) { }
                Button("Xóa", role: .destructive) {
                    if let movie = movieToDelete {
                        favorites.removeAll { $0.id == movie.id }
                    } else {
                        favorites.removeAll()
                    }
                    saveFavorites()
                }
            } message: {
                if movieToDelete != nil {
                    Text("Bạn có chắc muốn xóa phim này?")
                } else {
                    Text("Bạn có chắc muốn xóa tất cả phim yêu thích?")
                }
            }
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: "favorites")
        }
    }
}

struct MovieRow: View {
    let movie: Movie
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Thumbnail placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.6), Color.purple.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 80)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(formatDate(movie.addedDate))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let videoURL = movie.videoURL {
                        Text("📹 \(videoURL)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 5)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
}
