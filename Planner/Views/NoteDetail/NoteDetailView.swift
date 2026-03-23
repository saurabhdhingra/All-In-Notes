//
//  NoteDetailView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 09/06/25.
//

import SwiftUI
import UIKit
import PhotosUI
import SwiftData
import AVKit
import UniformTypeIdentifiers


// MARK: - Enhanced NoteDetailView (Always Editing)
@available(iOS 26.0, *)
struct NoteDetailView: View {
    @Bindable var note: Note
    @Environment(\.modelContext) private var context
    @Query(sort: \Tag.createdAt) private var tags: [Tag]
    @State private var selectedTag: String = "Work"
    @Environment(\.dismiss) private var dismiss
    @State private var keyboardHeight: CGFloat = 0

    // Media picker states
    @State private var showPhotoPicker = false
    @State private var showVideoPicker = false
    @State private var showVoiceRecorder = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedVideoItem: PhotosPickerItem?

    // Reference to block editor for inserting media
    @State private var blockEditorRef = BlockEditorRef()

    // Active text view manager for rich text formatting
    @State private var activeTextViewManager = ActiveTextViewManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    titleSection
                    tagPicker
                    timestampView
                    contentArea

                    Spacer()
                        .frame(height: 20)
                }
            }
            .scrollContentBackground(.hidden)
            .safeAreaInset(edge: .bottom) {
                if keyboardHeight > 0 {
                    EditorToolbar(
                        onAddPhoto: { showPhotoPicker = true },
                        onAddVideo: { showVideoPicker = true },
                        onAddVoiceNote: { showVoiceRecorder = true },
                        onDismissKeyboard: { dismissKeyboard() },
                        onBold: { activeTextViewManager.toggleBold() },
                        onItalic: { activeTextViewManager.toggleItalic() },
                        onUnderline: { activeTextViewManager.toggleUnderline() },
                        onBulletList: { activeTextViewManager.insertBullet() }
                    )
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.25)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            selectedTag = note.category.isEmpty ? selectedTag : note.category
            // Migrate legacy content if needed
            if note.blocks.isEmpty {
                note.migrateToBlocks()
                // Add initial text block if still empty
                if note.blocks.isEmpty {
                    let textBlock = ContentBlock.text(order: 0, content: "")
                    note.appendBlock(textBlock)
                }
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .photosPicker(
            isPresented: $showVideoPicker,
            selection: $selectedVideoItem,
            matching: .videos
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            if let item = newItem {
                Task { await handlePickedPhoto(item) }
            }
        }
        .onChange(of: selectedVideoItem) { _, newItem in
            if let item = newItem {
                Task { await handlePickedVideo(item) }
            }
        }
        .sheet(isPresented: $showVoiceRecorder) {
            VoiceRecordingSheet(
                onComplete: { data, duration in
                    insertVoiceNote(data: data, duration: duration)
                    showVoiceRecorder = false
                },
                onCancel: {
                    showVoiceRecorder = false
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Content Area with Block Editor
@available(iOS 26.0, *)
extension NoteDetailView {
    private var contentArea: some View {
        BlockEditorView(note: note, activeTextViewManager: activeTextViewManager)
            .frame(minHeight: 200)
            .padding(.horizontal)
    }
}

// MARK: - Media Handling
@available(iOS 26.0, *)
extension NoteDetailView {
    private func handlePickedPhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        // Compress image using processImage
        let compressedData = await MediaManager.shared.processImage(image)

        // Create photo block
        let attachment = MediaAttachment(
            type: .photo,
            filename: "photo_\(UUID().uuidString).jpg",
            data: compressedData ?? data
        )

        let photoBlock = ContentBlock.photo(order: note.blocks.count, attachment: attachment)

        await MainActor.run {
            note.appendBlock(photoBlock)
            selectedPhotoItem = nil
        }
    }

    private func handlePickedVideo(_ item: PhotosPickerItem) async {
        // Load video using Movie transferable type
        guard let movie = try? await item.loadTransferable(type: VideoPickerTransferable.self) else {
            print("Failed to load video")
            return
        }

        let sourceURL = movie.url

        // Generate thumbnail
        let thumbnailData = await MediaManager.shared.generateVideoThumbnail(from: sourceURL)

        // Get video duration
        let duration = await MediaManager.shared.getVideoDuration(from: sourceURL)

        // Save video directly (skip compression for now to ensure it works)
        do {
            let savedFilename = try MediaManager.shared.saveVideoToDocuments(from: sourceURL)

            // Create video block
            let attachment = MediaAttachment(
                type: .video,
                filename: savedFilename,
                data: Data(),
                duration: duration,
                thumbnailData: thumbnailData,
                filePath: savedFilename
            )

            let videoBlock = ContentBlock.video(order: note.blocks.count, attachment: attachment)
            await MainActor.run {
                note.appendBlock(videoBlock)
                selectedVideoItem = nil
            }
        } catch {
            print("Failed to save video: \(error)")
        }
    }

    private func insertVoiceNote(data: Data, duration: Double) {
        let attachment = MediaAttachment(
            type: .voiceNote,
            filename: "voice_\(UUID().uuidString).m4a",
            data: data,
            duration: duration
        )

        let voiceBlock = ContentBlock.voiceNote(order: note.blocks.count, attachment: attachment)
        note.appendBlock(voiceBlock)
    }
}

@available(iOS 26.0, *)
extension NoteDetailView {
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primary)
            }

            Spacer()

            Menu {
                Button(action: {}) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    context.delete(note)
                    dismiss()
                } label: {
                    Label("Delete Note", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var titleSection: some View {
        TextField("Title", text: $note.title)
            .font(.largeTitle.bold())
            .lineLimit(1)
            .padding(.horizontal)
    }

    private var timestampView: some View {
        Text("Last updated on \(note.lastUpdated, formatter: DateFormatter.mediumDateFormatter)")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }


    private var tagPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tags) { tag in
                    TagChipView(tag: tag, isSelected: selectedTag == tag.name)
                        .onTapGesture {
                            selectedTag = tag.name
                            note.category = tag.name
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Tag Chip View
struct TagChipView: View {
    let tag: Tag
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tag.color)
                .frame(width: 8, height: 8)

            Text(tag.name)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? tag.color.opacity(0.3) : Color.gray.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? tag.color : Color.clear, lineWidth: 2)
        )
        .foregroundColor(isSelected ? tag.color : .primary)
    }
}

// MARK: - Block Editor Reference
/// Helper class to maintain reference to block editor for media insertion
class BlockEditorRef {
    weak var editor: AnyObject?
}

// MARK: - Video Picker Transferable
/// Transferable type for loading videos from PhotosPicker
struct VideoPickerTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            // Copy to temporary location
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            try FileManager.default.copyItem(at: received.file, to: tempURL)
            return Self(url: tempURL)
        }
    }
}
