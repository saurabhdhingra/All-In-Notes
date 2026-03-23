//
//  MediaAttachment.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import Foundation
import SwiftData

/// Represents a media file attached to a note content block
@Model
class MediaAttachment {
    @Attribute(.unique) var id: UUID
    var type: MediaType
    var filename: String
    var createdAt: Date

    /// The actual media data - stored externally for performance
    @Attribute(.externalStorage) var data: Data

    /// Duration in seconds for video and voice notes
    var duration: Double?

    /// Thumbnail image data for video previews
    @Attribute(.externalStorage) var thumbnailData: Data?

    /// File size in bytes (for display purposes)
    var fileSize: Int64

    /// For videos stored in Documents folder, this holds the relative path
    var filePath: String?

    init(
        id: UUID = UUID(),
        type: MediaType,
        filename: String,
        data: Data,
        duration: Double? = nil,
        thumbnailData: Data? = nil,
        filePath: String? = nil
    ) {
        self.id = id
        self.type = type
        self.filename = filename
        self.createdAt = Date()
        self.data = data
        self.duration = duration
        self.thumbnailData = thumbnailData
        self.fileSize = Int64(data.count)
        self.filePath = filePath
    }

    /// Formatted file size string (e.g., "2.4 MB")
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }

    /// Formatted duration string (e.g., "1:30")
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Media Type Enum
extension MediaAttachment {
    enum MediaType: String, Codable, CaseIterable {
        case photo
        case video
        case voiceNote

        var systemImage: String {
            switch self {
            case .photo: return "photo"
            case .video: return "video"
            case .voiceNote: return "mic"
            }
        }

        var displayName: String {
            switch self {
            case .photo: return "Photo"
            case .video: return "Video"
            case .voiceNote: return "Voice Note"
            }
        }
    }
}
