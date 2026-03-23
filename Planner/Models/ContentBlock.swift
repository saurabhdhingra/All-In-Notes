//
//  ContentBlock.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import Foundation
import SwiftData
import UIKit

/// Represents a single block of content within a note
/// Notes are composed of ordered blocks that can be text, photos, videos, or voice notes
@Model
class ContentBlock {
    @Attribute(.unique) var id: UUID

    /// Order index for sorting blocks within a note
    var order: Int

    /// The type of content this block contains
    var type: BlockType

    /// Text content for text blocks - stored externally for large content
    @Attribute(.externalStorage) var textContent: String?

    /// Rich text data (serialized NSAttributedString) for text blocks
    @Attribute(.externalStorage) var richTextData: Data?

    /// Media attachment for photo/video/voice note blocks
    @Relationship(deleteRule: .cascade) var media: MediaAttachment?

    /// Reference to parent note (inverse relationship)
    var note: Note?

    /// Timestamp when this block was created
    var createdAt: Date

    /// Timestamp when this block was last modified
    var lastModified: Date

    init(
        id: UUID = UUID(),
        order: Int,
        type: BlockType,
        textContent: String? = nil,
        media: MediaAttachment? = nil
    ) {
        self.id = id
        self.order = order
        self.type = type
        self.textContent = textContent
        self.media = media
        self.createdAt = Date()
        self.lastModified = Date()
    }

    /// Convenience initializer for text blocks
    static func text(order: Int, content: String) -> ContentBlock {
        ContentBlock(order: order, type: .text, textContent: content)
    }

    /// Convenience initializer for photo blocks
    static func photo(order: Int, attachment: MediaAttachment) -> ContentBlock {
        ContentBlock(order: order, type: .photo, media: attachment)
    }

    /// Convenience initializer for video blocks
    static func video(order: Int, attachment: MediaAttachment) -> ContentBlock {
        ContentBlock(order: order, type: .video, media: attachment)
    }

    /// Convenience initializer for voice note blocks
    static func voiceNote(order: Int, attachment: MediaAttachment) -> ContentBlock {
        ContentBlock(order: order, type: .voiceNote, media: attachment)
    }

    /// Update the last modified timestamp
    func touch() {
        lastModified = Date()
    }

    // MARK: - Rich Text Helpers

    /// Get the attributed string from stored data
    var attributedText: NSAttributedString? {
        guard let data = richTextData else {
            // Fall back to plain text if no rich text data
            if let text = textContent {
                return NSAttributedString(string: text)
            }
            return nil
        }

        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.rtfd],
                documentAttributes: nil
            )
        } catch {
            // Try RTF format as fallback
            do {
                return try NSAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.rtf],
                    documentAttributes: nil
                )
            } catch {
                // Last resort: plain text
                if let text = textContent {
                    return NSAttributedString(string: text)
                }
                return nil
            }
        }
    }

    /// Set the attributed string and store as data
    func setAttributedText(_ attributedString: NSAttributedString) {
        do {
            richTextData = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
            )
            // Also store plain text for search/preview
            textContent = attributedString.string
            touch()
        } catch {
            // Fallback to plain text
            textContent = attributedString.string
            richTextData = nil
            touch()
        }
    }
}

// MARK: - Block Type Enum
extension ContentBlock {
    enum BlockType: String, Codable, CaseIterable {
        case text
        case photo
        case video
        case voiceNote

        var systemImage: String {
            switch self {
            case .text: return "text.alignleft"
            case .photo: return "photo"
            case .video: return "video"
            case .voiceNote: return "mic"
            }
        }

        var isMedia: Bool {
            switch self {
            case .text: return false
            case .photo, .video, .voiceNote: return true
            }
        }
    }
}

// MARK: - Comparable for sorting
extension ContentBlock: Comparable {
    static func < (lhs: ContentBlock, rhs: ContentBlock) -> Bool {
        lhs.order < rhs.order
    }
}

// MARK: - Identifiable conformance
extension ContentBlock: Identifiable {}
