//
//  EditorToolbar.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import PhotosUI
import AVFoundation
import UIKit

/// Toolbar that appears above the keyboard with formatting and media options
struct EditorToolbar: View {
    var onAddPhoto: () -> Void
    var onAddVideo: () -> Void
    var onAddVoiceNote: () -> Void
    var onDismissKeyboard: () -> Void
    var onBold: (() -> Void)?
    var onItalic: (() -> Void)?
    var onUnderline: (() -> Void)?
    var onBulletList: (() -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            // Formatting buttons
            if onBold != nil {
                Button(action: { onBold?() }) {
                    Image(systemName: "bold")
                        .font(.title3)
                        .foregroundColor(.primary)
                }

                Button(action: { onItalic?() }) {
                    Image(systemName: "italic")
                        .font(.title3)
                        .foregroundColor(.primary)
                }

                Button(action: { onUnderline?() }) {
                    Image(systemName: "underline")
                        .font(.title3)
                        .foregroundColor(.primary)
                }

                Button(action: { onBulletList?() }) {
                    Image(systemName: "list.bullet")
                        .font(.title3)
                        .foregroundColor(.primary)
                }

                Divider()
                    .frame(height: 20)
            }

            // Photo button
            Button(action: onAddPhoto) {
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Add Photo")

            // Video button
            Button(action: onAddVideo) {
                Image(systemName: "video")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Add Video")

            // Voice note button
            Button(action: onAddVoiceNote) {
                Image(systemName: "mic")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Record Voice Note")

            Spacer()

            // Dismiss keyboard button
            Button(action: onDismissKeyboard) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel("Dismiss Keyboard")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Voice Recording Sheet
struct VoiceRecordingSheet: View {
    @StateObject private var recorder = VoiceRecorder()
    @State private var recordedData: Data?
    @State private var recordedDuration: Double = 0
    @State private var isReviewing = false
    @State private var isPlayingPreview = false
    @State private var previewPlayer: AVAudioPlayer?

    var onComplete: (Data, Double) -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button("Cancel") {
                    cleanup()
                    onCancel()
                }
                .frame(width: 60, alignment: .leading)

                Spacer()

                Text(isReviewing ? "Review" : "Voice Note")
                    .font(.headline)

                Spacer()

                Button("Save") {
                    if let data = recordedData {
                        onComplete(data, recordedDuration)
                    }
                }
                .fontWeight(.semibold)
                .foregroundColor(isReviewing ? .accentColor : .gray)
                .disabled(!isReviewing)
                .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            if isReviewing {
                // Review mode - playback UI
                reviewView
            } else {
                // Recording mode
                recordingView
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 && !isReviewing {
                        recorder.cancelRecording()
                        onCancel()
                    }
                }
        )
        .onDisappear {
            cleanup()
        }
    }

    // MARK: - Recording View
    private var recordingView: some View {
        VStack(spacing: 20) {
            Spacer()

            // Recording visualization - fixed frame to prevent layout shifts
            ZStack {
                // Audio level circle (contained within fixed frame)
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .scaleEffect(1 + CGFloat(recorder.audioLevel * 0.3))
                    .frame(width: 150, height: 150)
                    .animation(.easeInOut(duration: 0.1), value: recorder.audioLevel)

                // Main circle
                Circle()
                    .fill(recorder.isRecording ? Color.red : Color.secondary.opacity(0.3))
                    .frame(width: 120, height: 120)

                // Mic icon
                Image(systemName: "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .frame(width: 200, height: 200)

            // Duration
            Text(recorder.formattedDuration)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(.primary)

            Text("Max: \(recorder.formattedMaxDuration)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            // Record/Stop button
            if recorder.isRecording {
                Button(action: stopAndReview) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                    }
                }
            } else {
                Button(action: {
                    Task {
                        try? await recorder.startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.red, lineWidth: 4)
                            .frame(width: 70, height: 70)

                        Circle()
                            .fill(Color.red)
                            .frame(width: 54, height: 54)
                    }
                }
            }

            // Hint text
            Text(recorder.isRecording ? "Tap to stop" : "Tap to record")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
                .frame(height: 40)
        }
    }

    // MARK: - Review View
    private var reviewView: some View {
        VStack(spacing: 20) {
            Spacer()

            // Playback button
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 150, height: 150)

                Circle()
                    .fill(Color.green)
                    .frame(width: 120, height: 120)

                Image(systemName: isPlayingPreview ? "pause.fill" : "play.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .frame(width: 200, height: 200)
            .onTapGesture {
                togglePreviewPlayback()
            }

            // Duration
            Text(formatDuration(recordedDuration))
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(.primary)

            Text("Tap to preview")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            // Re-record button
            Button(action: reRecord) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Re-record")
                }
                .foregroundColor(.red)
            }

            Spacer()
                .frame(height: 40)
        }
    }

    // MARK: - Actions

    private func stopAndReview() {
        // Capture duration before stopping (stopRecording may clear it)
        let currentDuration = recorder.duration

        if let data = recorder.stopRecording() {
            recordedData = data
            recordedDuration = currentDuration > 0 ? currentDuration : 1.0
            isReviewing = true
        } else {
            // If stopRecording returns nil, still try to transition to review
            // This handles edge cases
            print("Warning: stopRecording returned nil")
        }
    }

    private func togglePreviewPlayback() {
        guard let data = recordedData else { return }

        if isPlayingPreview {
            previewPlayer?.stop()
            isPlayingPreview = false
        } else {
            do {
                previewPlayer = try AVAudioPlayer(data: data)
                previewPlayer?.play()
                isPlayingPreview = true

                // Auto-stop when done
                DispatchQueue.main.asyncAfter(deadline: .now() + recordedDuration) {
                    isPlayingPreview = false
                }
            } catch {
                print("Error playing preview: \(error)")
            }
        }
    }

    private func reRecord() {
        previewPlayer?.stop()
        isPlayingPreview = false
        recordedData = nil
        recordedDuration = 0
        isReviewing = false
    }

    private func cleanup() {
        previewPlayer?.stop()
        previewPlayer = nil
        recorder.cancelRecording()
    }

    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview {
    EditorToolbar(
        onAddPhoto: {},
        onAddVideo: {},
        onAddVoiceNote: {},
        onDismissKeyboard: {}
    )
}
