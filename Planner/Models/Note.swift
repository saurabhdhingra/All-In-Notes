//
//  Note.swift
//  Planner
//
//  Created by Saurabh Dhingra on 11/06/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Note {
    @Attribute(.unique) var id: UUID
    var title: String
    var lastUpdated: Date
    var category: String

    /// Ordered content blocks that make up the note body
    @Relationship(deleteRule: .cascade, inverse: \ContentBlock.note)
    var blocks: [ContentBlock]

    // MARK: - Legacy properties (kept for migration)
    /// @deprecated Use blocks instead
    var legacyContent: String?
    /// @deprecated Use blocks with media attachments instead
    @Attribute(.externalStorage) var imageData: Data?

    init(
        id: UUID = UUID(),
        title: String,
        lastUpdated: Date = Date(),
        category: String = "",
        blocks: [ContentBlock] = []
    ) {
        self.id = id
        self.title = title
        self.lastUpdated = lastUpdated
        self.category = category
        self.blocks = blocks
        self.legacyContent = nil
        self.imageData = nil
    }

    /// Legacy initializer for backward compatibility
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        lastUpdated: Date,
        category: String,
        imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.lastUpdated = lastUpdated
        self.category = category
        self.legacyContent = content
        self.imageData = imageData
        self.blocks = []
    }

    // MARK: - Block Management

    /// Returns blocks sorted by their order
    var sortedBlocks: [ContentBlock] {
        blocks.sorted { $0.order < $1.order }
    }

    /// Add a new block at the end
    func appendBlock(_ block: ContentBlock) {
        block.order = (blocks.map(\.order).max() ?? -1) + 1
        block.note = self
        blocks.append(block)
        touch()
    }

    /// Insert a block at a specific index
    func insertBlock(_ block: ContentBlock, at index: Int) {
        // Shift existing blocks
        for existingBlock in blocks where existingBlock.order >= index {
            existingBlock.order += 1
        }
        block.order = index
        block.note = self
        blocks.append(block)
        touch()
    }

    /// Remove a block
    func removeBlock(_ block: ContentBlock) {
        let removedOrder = block.order
        blocks.removeAll { $0.id == block.id }
        // Reorder remaining blocks
        for existingBlock in blocks where existingBlock.order > removedOrder {
            existingBlock.order -= 1
        }
        touch()
    }

    /// Move a block from one position to another
    func moveBlock(from sourceIndex: Int, to destinationIndex: Int) {
        guard let block = blocks.first(where: { $0.order == sourceIndex }) else { return }

        if sourceIndex < destinationIndex {
            // Moving down
            for existingBlock in blocks where existingBlock.order > sourceIndex && existingBlock.order <= destinationIndex {
                existingBlock.order -= 1
            }
        } else {
            // Moving up
            for existingBlock in blocks where existingBlock.order >= destinationIndex && existingBlock.order < sourceIndex {
                existingBlock.order += 1
            }
        }
        block.order = destinationIndex
        touch()
    }

    /// Update the last modified timestamp
    func touch() {
        lastUpdated = Date()
    }

    // MARK: - Content Helpers

    /// Get plain text content from all text blocks (for search/preview)
    var plainTextContent: String {
        let blockText = sortedBlocks
            .compactMap { $0.textContent }
            .joined(separator: "\n")

        // Fall back to legacy content if blocks are empty
        if blockText.isEmpty, let legacy = legacyContent {
            return legacy
        }
        return blockText
    }

    /// Check if note has any media
    var hasMedia: Bool {
        blocks.contains { $0.type.isMedia }
    }

    /// Get first image data for preview (from blocks or legacy)
    var previewImageData: Data? {
        if let photoBlock = sortedBlocks.first(where: { $0.type == .photo }),
           let media = photoBlock.media {
            return media.data
        }
        return imageData // Fallback to legacy
    }

    // MARK: - Migration

    /// Migrate legacy content to block-based system
    func migrateToBlocks() {
        guard blocks.isEmpty else { return }

        var order = 0

        // Migrate text content
        if let legacy = legacyContent, !legacy.isEmpty {
            let textBlock = ContentBlock.text(order: order, content: legacy)
            textBlock.note = self
            blocks.append(textBlock)
            order += 1
        }

        // Migrate image data
        if let legacyImageData = imageData {
            let attachment = MediaAttachment(
                type: .photo,
                filename: "migrated_image.jpg",
                data: legacyImageData
            )
            let photoBlock = ContentBlock.photo(order: order, attachment: attachment)
            photoBlock.note = self
            blocks.append(photoBlock)
        }
    }
}
