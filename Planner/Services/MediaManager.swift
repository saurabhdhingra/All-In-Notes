//
//  MediaManager.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import Foundation
import UIKit
import AVFoundation
import Photos

/// Service for handling media compression, processing, and storage
@MainActor
class MediaManager: ObservableObject {
    static let shared = MediaManager()

    // MARK: - Configuration
    struct Config {
        static let maxImageSize: CGFloat = 1920
        static let imageCompressionQuality: CGFloat = 0.7
        static let maxVideoLength: TimeInterval = 180 // 3 minutes
        static let videoExportPreset = AVAssetExportPresetMediumQuality
        static let maxVoiceNoteLength: TimeInterval = 300 // 5 minutes
    }

    // MARK: - Image Processing

    /// Compress and resize an image for storage
    func processImage(_ image: UIImage) -> Data? {
        let resizedImage = resizeImage(image, maxSize: Config.maxImageSize)
        return resizedImage.jpegData(compressionQuality: Config.imageCompressionQuality)
    }

    /// Resize image maintaining aspect ratio
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size

        guard size.width > maxSize || size.height > maxSize else {
            return image
        }

        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Create a thumbnail from image data
    func createThumbnail(from imageData: Data, size: CGSize = CGSize(width: 200, height: 200)) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        let thumbnail = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

        return thumbnail.jpegData(compressionQuality: 0.6)
    }

    // MARK: - Video Processing

    /// Get video duration from URL
    func getVideoDuration(from url: URL) async -> TimeInterval? {
        let asset = AVURLAsset(url: url)
        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            print("Error getting video duration: \(error)")
            return nil
        }
    }

    /// Generate thumbnail from video
    func generateVideoThumbnail(from url: URL) async -> Data? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try await imageGenerator.image(at: .zero).image
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage.jpegData(compressionQuality: 0.7)
        } catch {
            print("Error generating video thumbnail: \(error)")
            return nil
        }
    }

    /// Compress video for storage
    func compressVideo(from sourceURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let outputURL = getDocumentsDirectory()
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        let asset = AVURLAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: Config.videoExportPreset
        ) else {
            completion(.failure(MediaError.compressionFailed))
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(.success(outputURL))
            case .failed:
                completion(.failure(exportSession.error ?? MediaError.compressionFailed))
            case .cancelled:
                completion(.failure(MediaError.cancelled))
            default:
                completion(.failure(MediaError.unknown))
            }
        }
    }

    /// Save video to documents directory
    func saveVideoToDocuments(from sourceURL: URL) throws -> String {
        let filename = UUID().uuidString + ".mp4"
        let destinationURL = getVideosDirectory().appendingPathComponent(filename)

        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        return filename
    }

    /// Get video URL from filename
    func getVideoURL(filename: String) -> URL {
        getVideosDirectory().appendingPathComponent(filename)
    }

    /// Delete video file
    func deleteVideo(filename: String) {
        let url = getVideoURL(filename: filename)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - File System Helpers

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func getVideosDirectory() -> URL {
        let videosDir = getDocumentsDirectory().appendingPathComponent("Videos")
        if !FileManager.default.fileExists(atPath: videosDir.path) {
            try? FileManager.default.createDirectory(at: videosDir, withIntermediateDirectories: true)
        }
        return videosDir
    }

    // MARK: - Validation

    /// Check if video duration is within limits
    func isVideoWithinLimits(duration: TimeInterval) -> Bool {
        duration <= Config.maxVideoLength
    }

    /// Get formatted size string
    func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Errors
extension MediaManager {
    enum MediaError: LocalizedError {
        case compressionFailed
        case cancelled
        case videoTooLong
        case unknown

        var errorDescription: String? {
            switch self {
            case .compressionFailed:
                return "Failed to compress media"
            case .cancelled:
                return "Operation was cancelled"
            case .videoTooLong:
                return "Video exceeds maximum length of 3 minutes"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
}
