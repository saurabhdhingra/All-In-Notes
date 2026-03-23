//
//  BlockEditorView.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import SwiftData

/// Main editor view that displays and manages content blocks
struct BlockEditorView: View {
    @Bindable var note: Note
    var activeTextViewManager: ActiveTextViewManager?
    @FocusState private var focusedBlockId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if note.blocks.isEmpty {
                emptyStateView
            } else {
                ForEach(note.sortedBlocks) { block in
                    blockView(for: block)
                        .id(block.id)
                }
            }
        }
        .frame(minHeight: 100)
    }

    // MARK: - Block Views

    @ViewBuilder
    private func blockView(for block: ContentBlock) -> some View {
        switch block.type {
        case .text:
            TextBlockView(
                block: block,
                focusedBlockId: $focusedBlockId,
                onDelete: { deleteBlock(block) },
                activeTextViewManager: activeTextViewManager
            )

        case .photo:
            PhotoBlockView(
                block: block,
                onDelete: { deleteBlock(block) },
                onTap: { /* Handle fullscreen */ }
            )

        case .video:
            VideoBlockView(
                block: block,
                onDelete: { deleteBlock(block) }
            )

        case .voiceNote:
            VoiceNoteBlockView(
                block: block,
                onDelete: { deleteBlock(block) }
            )
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.cursor")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("Tap to start writing")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onTapGesture {
            addTextBlock()
        }
    }

    // MARK: - Block Management

    private func addTextBlock() {
        let newBlock = ContentBlock.text(order: note.blocks.count, content: "")
        note.appendBlock(newBlock)
        focusedBlockId = newBlock.id
    }

    private func deleteBlock(_ block: ContentBlock) {
        note.removeBlock(block)
    }
}

// MARK: - Block Actions
extension BlockEditorView {
    /// Insert a new text block after the specified block
    func insertTextBlock(after block: ContentBlock) {
        let newBlock = ContentBlock.text(order: block.order + 1, content: "")
        note.insertBlock(newBlock, at: block.order + 1)
        focusedBlockId = newBlock.id
    }

    /// Insert a photo block
    func insertPhotoBlock(imageData: Data, after block: ContentBlock? = nil) {
        let attachment = MediaAttachment(
            type: .photo,
            filename: "photo_\(UUID().uuidString).jpg",
            data: imageData
        )

        let order = block.map { $0.order + 1 } ?? note.blocks.count
        let photoBlock = ContentBlock.photo(order: order, attachment: attachment)

        if let existingBlock = block {
            note.insertBlock(photoBlock, at: existingBlock.order + 1)
        } else {
            note.appendBlock(photoBlock)
        }
    }

    /// Insert a video block
    func insertVideoBlock(
        videoPath: String,
        thumbnailData: Data?,
        duration: Double,
        after block: ContentBlock? = nil
    ) {
        let attachment = MediaAttachment(
            type: .video,
            filename: videoPath,
            data: Data(), // Video data stored in file
            duration: duration,
            thumbnailData: thumbnailData,
            filePath: videoPath
        )

        let order = block.map { $0.order + 1 } ?? note.blocks.count
        let videoBlock = ContentBlock.video(order: order, attachment: attachment)

        if let existingBlock = block {
            note.insertBlock(videoBlock, at: existingBlock.order + 1)
        } else {
            note.appendBlock(videoBlock)
        }
    }

    /// Insert a voice note block
    func insertVoiceNoteBlock(audioData: Data, duration: Double, after block: ContentBlock? = nil) {
        let attachment = MediaAttachment(
            type: .voiceNote,
            filename: "voice_\(UUID().uuidString).m4a",
            data: audioData,
            duration: duration
        )

        let order = block.map { $0.order + 1 } ?? note.blocks.count
        let voiceBlock = ContentBlock.voiceNote(order: order, attachment: attachment)

        if let existingBlock = block {
            note.insertBlock(voiceBlock, at: existingBlock.order + 1)
        } else {
            note.appendBlock(voiceBlock)
        }
    }
}
