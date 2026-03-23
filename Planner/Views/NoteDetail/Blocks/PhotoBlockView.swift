//
//  PhotoBlockView.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import SwiftData

/// View for displaying a photo content block
struct PhotoBlockView: View {
    let block: ContentBlock
    var onDelete: () -> Void
    var onTap: () -> Void

    @State private var isShowingFullscreen = false

    var body: some View {
        Group {
            if let media = block.media,
               let uiImage = UIImage(data: media.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        isShowingFullscreen = true
                    }
                    .contextMenu {
                        Button(action: { isShowingFullscreen = true }) {
                            Label("View Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete Photo", systemImage: "trash")
                        }
                    }
            } else {
                // Placeholder for missing image
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    }
            }
        }
        .fullScreenCover(isPresented: $isShowingFullscreen) {
            FullscreenImageView(
                imageData: block.media?.data,
                onDismiss: { isShowingFullscreen = false }
            )
        }
    }
}

// MARK: - Fullscreen Image View
struct FullscreenImageView: View {
    let imageData: Data?
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                if scale < 1.0 {
                                    withAnimation {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
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
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        onDismiss()
                    }
                }
        )
    }
}
