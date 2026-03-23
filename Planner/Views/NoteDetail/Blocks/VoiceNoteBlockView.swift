//
//  VoiceNoteBlockView.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import SwiftData
import AVFoundation

/// View for displaying and playing a voice note content block
struct VoiceNoteBlockView: View {
    let block: ContentBlock
    var onDelete: () -> Void

    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var player: AVAudioPlayer?
    @State private var playbackTimer: Timer?
    @State private var playbackSpeed: Float = 1.0

    private let speedOptions: [Float] = [1.0, 1.5, 2.0]

    var body: some View {
        HStack(spacing: 12) {
            // Play/Pause button
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)

                        // Progress
                        Capsule()
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)

                // Duration
                HStack {
                    Text(formattedCurrentTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()

                    Spacer()

                    if let duration = block.media?.formattedDuration {
                        Text(duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                }
            }

            // Speed button
            Button(action: cycleSpeed) {
                Text("\(playbackSpeed, specifier: "%.1f")x")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Voice Note", systemImage: "trash")
            }
        }
        .onDisappear {
            stopPlayback()
        }
    }

    // MARK: - Computed Properties

    private var formattedCurrentTime: String {
        guard let player = player else { return "0:00" }
        let time = player.currentTime
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Playback Controls

    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard let media = block.media else { return }

        // Initialize player if needed
        if player == nil {
            do {
                player = try AVAudioPlayer(data: media.data)
                player?.enableRate = true
                player?.rate = playbackSpeed
                player?.prepareToPlay()
            } catch {
                print("Error creating audio player: \(error)")
                return
            }
        }

        player?.play()
        isPlaying = true
        startProgressTimer()
    }

    private func pausePlayback() {
        player?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    private func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        stopProgressTimer()
    }

    private func cycleSpeed() {
        guard let currentIndex = speedOptions.firstIndex(of: playbackSpeed) else {
            playbackSpeed = 1.0
            return
        }
        let nextIndex = (currentIndex + 1) % speedOptions.count
        playbackSpeed = speedOptions[nextIndex]
        player?.rate = playbackSpeed
    }

    // MARK: - Progress Timer

    private func startProgressTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = player else { return }

            if player.isPlaying {
                progress = player.currentTime / player.duration
            } else {
                // Playback finished
                isPlaying = false
                progress = 0
                player.currentTime = 0
                stopProgressTimer()
            }
        }
    }

    private func stopProgressTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
