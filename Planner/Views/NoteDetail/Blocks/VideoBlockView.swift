//
//  VideoBlockView.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import SwiftData
import AVKit

/// View for displaying a video content block
struct VideoBlockView: View {
    let block: ContentBlock
    var onDelete: () -> Void

    @State private var isShowingPlayer = false
    @State private var isLoading = false
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            // Thumbnail
            if let media = block.media,
               let thumbnailData = media.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 200)
            }

            // Play button or loading indicator
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(.ultraThinMaterial))
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "play.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                            .offset(x: 2)
                    }
            }

            // Duration badge
            if let duration = block.media?.formattedDuration {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.7))
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            if !isLoading {
                loadAndPlayVideo()
            }
        }
        .contextMenu {
            Button(action: { loadAndPlayVideo() }) {
                Label("Play Video", systemImage: "play")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete Video", systemImage: "trash")
            }
        }
        .fullScreenCover(isPresented: $isShowingPlayer) {
            VideoPlayerView(player: player, onDismiss: {
                player?.pause()
                player = nil
                isShowingPlayer = false
            })
        }
    }

    private func loadAndPlayVideo() {
        guard let media = block.media,
              let filePath = media.filePath else { return }

        isLoading = true

        let url = MediaManager.shared.getVideoURL(filename: filePath)
        let asset = AVURLAsset(url: url)

        Task {
            do {
                // Preload the video tracks
                let _ = try await asset.load(.tracks, .duration, .isPlayable)

                await MainActor.run {
                    let playerItem = AVPlayerItem(asset: asset)
                    let newPlayer = AVPlayer(playerItem: playerItem)
                    newPlayer.actionAtItemEnd = .pause

                    self.player = newPlayer
                    self.isLoading = false
                    self.isShowingPlayer = true

                    // Start playing after a brief delay to ensure view is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        newPlayer.play()
                    }
                }
            } catch {
                print("Error loading video: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    let player: AVPlayer?
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onDisappear {
            player?.pause()
        }
    }
}
