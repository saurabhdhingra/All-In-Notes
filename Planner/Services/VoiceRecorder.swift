//
//  VoiceRecorder.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import Foundation
import AVFoundation
import Combine

/// Service for recording voice notes
@MainActor
class VoiceRecorder: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var duration: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var recordingState: RecordingState = .idle

    // MARK: - Private Properties
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var levelTimer: Timer?
    private var recordingURL: URL?

    static let maxDuration: TimeInterval = 300 // 5 minutes

    // MARK: - Recording State
    enum RecordingState {
        case idle
        case recording
        case paused
        case finished(URL)
        case error(Error)
    }

    // MARK: - Initialization
    override init() {
        super.init()
    }

    // MARK: - Permission
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Recording Controls

    /// Start a new recording
    func startRecording() async throws {
        // Request permission first
        guard await requestPermission() else {
            throw RecordingError.permissionDenied
        }

        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        // Create recording URL
        let filename = UUID().uuidString + ".m4a"
        recordingURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        guard let url = recordingURL else {
            throw RecordingError.invalidURL
        }

        // Recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // Create recorder
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.delegate = self

        // Start recording
        audioRecorder?.record()
        isRecording = true
        isPaused = false
        duration = 0
        recordingState = .recording

        // Start timers
        startTimers()
    }

    /// Pause recording
    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        isPaused = true
        recordingState = .paused
        stopTimers()
    }

    /// Resume recording
    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        isPaused = false
        recordingState = .recording
        startTimers()
    }

    /// Stop recording and return the data
    func stopRecording() -> Data? {
        guard isRecording else { return nil }

        audioRecorder?.stop()
        stopTimers()

        isRecording = false
        isPaused = false

        guard let url = recordingURL else {
            recordingState = .error(RecordingError.invalidURL)
            return nil
        }

        // Read the recorded data
        do {
            let data = try Data(contentsOf: url)
            recordingState = .finished(url)
            // Clean up the temp file after reading
            try? FileManager.default.removeItem(at: url)
            return data
        } catch {
            recordingState = .error(error)
            return nil
        }
    }

    /// Cancel recording without saving
    func cancelRecording() {
        audioRecorder?.stop()
        stopTimers()

        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }

        isRecording = false
        isPaused = false
        duration = 0
        audioLevel = 0
        recordingState = .idle
    }

    // MARK: - Timer Management
    private func startTimers() {
        // Duration timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.duration = self.audioRecorder?.currentTime ?? 0

                // Auto-stop at max duration
                if self.duration >= Self.maxDuration {
                    _ = self.stopRecording()
                }
            }
        }

        // Audio level timer
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.audioRecorder?.updateMeters()
                let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
                // Normalize from -160...0 to 0...1
                self.audioLevel = max(0, (level + 50) / 50)
            }
        }
    }

    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        levelTimer?.invalidate()
        levelTimer = nil
    }

    // MARK: - Formatting
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let tenths = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }

    var formattedMaxDuration: String {
        let minutes = Int(Self.maxDuration) / 60
        return "\(minutes) min"
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceRecorder: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                recordingState = .error(RecordingError.recordingFailed)
            }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            recordingState = .error(error ?? RecordingError.encodingFailed)
        }
    }
}

// MARK: - Errors
extension VoiceRecorder {
    enum RecordingError: LocalizedError {
        case permissionDenied
        case invalidURL
        case recordingFailed
        case encodingFailed

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Microphone access is required to record voice notes"
            case .invalidURL:
                return "Could not create recording file"
            case .recordingFailed:
                return "Recording failed"
            case .encodingFailed:
                return "Failed to encode audio"
            }
        }
    }
}
