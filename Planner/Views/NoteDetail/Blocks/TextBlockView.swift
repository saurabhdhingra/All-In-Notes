//
//  TextBlockView.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import SwiftData
import UIKit

/// View for displaying and editing a rich text content block
struct TextBlockView: View {
    @Bindable var block: ContentBlock
    var focusedBlockId: FocusState<UUID?>.Binding
    var onDelete: () -> Void
    var activeTextViewManager: ActiveTextViewManager?

    @State private var attributedText: NSAttributedString = NSAttributedString()
    @State private var hasLoadedInitialContent = false

    var body: some View {
        RichTextEditor(
            attributedText: $attributedText,
            placeholder: "Start typing...",
            onTextChange: {
                saveContent()
            },
            activeTextViewManager: activeTextViewManager
        )
        .frame(minHeight: 44)
        .onAppear {
            loadContent()
        }
    }

    private func loadContent() {
        guard !hasLoadedInitialContent else { return }
        hasLoadedInitialContent = true

        if let existingText = block.attributedText {
            attributedText = existingText
        } else if let plainText = block.textContent, !plainText.isEmpty {
            attributedText = NSAttributedString(
                string: plainText,
                attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .body),
                    .foregroundColor: UIColor.label
                ]
            )
        }
    }

    private func saveContent() {
        block.setAttributedText(attributedText)
    }
}
