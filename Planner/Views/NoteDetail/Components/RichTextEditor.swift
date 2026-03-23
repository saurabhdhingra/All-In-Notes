//
//  RichTextEditor.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import UIKit

/// A rich text editor using UITextView for formatting support
struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var placeholder: String = "Start typing..."
    var onTextChange: (() -> Void)?
    var activeTextViewManager: ActiveTextViewManager?

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.isScrollEnabled = false // Allow auto-sizing
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Enable rich text features
        textView.allowsEditingTextAttributes = true
        textView.typingAttributes = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label
        ]

        // Store reference to coordinator for active view tracking
        context.coordinator.activeTextViewManager = activeTextViewManager

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        // Only update if text actually changed to avoid cursor jumping
        if textView.attributedText != attributedText {
            let selectedRange = textView.selectedRange
            textView.attributedText = attributedText

            // Restore cursor position if valid
            if selectedRange.location <= textView.text.count {
                textView.selectedRange = selectedRange
            }
        }

        // Update placeholder visibility
        context.coordinator.updatePlaceholder(textView, isEmpty: attributedText.length == 0)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var placeholderLabel: UILabel?
        var activeTextViewManager: ActiveTextViewManager?

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            // Register this text view as the active one for formatting
            activeTextViewManager?.activeTextView = textView
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText ?? NSAttributedString()
            parent.onTextChange?()
            updatePlaceholder(textView, isEmpty: textView.text.isEmpty)
        }

        func updatePlaceholder(_ textView: UITextView, isEmpty: Bool) {
            if placeholderLabel == nil {
                let label = UILabel()
                label.text = parent.placeholder
                label.font = UIFont.preferredFont(forTextStyle: .body)
                label.textColor = .placeholderText
                label.translatesAutoresizingMaskIntoConstraints = false
                textView.addSubview(label)

                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
                    label.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5)
                ])

                placeholderLabel = label
            }

            placeholderLabel?.isHidden = !isEmpty
        }
    }
}

// MARK: - Rich Text Formatting Toolbar
struct RichTextFormattingToolbar: View {
    @Binding var textView: UITextView?

    var body: some View {
        HStack(spacing: 16) {
            // Bold
            Button(action: { toggleBold() }) {
                Image(systemName: "bold")
                    .font(.title3)
            }

            // Italic
            Button(action: { toggleItalic() }) {
                Image(systemName: "italic")
                    .font(.title3)
            }

            // Underline
            Button(action: { toggleUnderline() }) {
                Image(systemName: "underline")
                    .font(.title3)
            }

            Divider()
                .frame(height: 20)

            // Bullet list
            Button(action: { insertBullet() }) {
                Image(systemName: "list.bullet")
                    .font(.title3)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    private func toggleBold() {
        guard let textView = textView else { return }
        toggleTrait(.traitBold, in: textView)
    }

    private func toggleItalic() {
        guard let textView = textView else { return }
        toggleTrait(.traitItalic, in: textView)
    }

    private func toggleUnderline() {
        guard let textView = textView else { return }

        let range = textView.selectedRange
        guard range.length > 0 else {
            // Toggle for typing attributes
            var typingAttributes = textView.typingAttributes
            if typingAttributes[.underlineStyle] != nil {
                typingAttributes.removeValue(forKey: .underlineStyle)
            } else {
                typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            textView.typingAttributes = typingAttributes
            return
        }

        let mutableAttrString = NSMutableAttributedString(attributedString: textView.attributedText)
        var hasUnderline = false

        mutableAttrString.enumerateAttribute(.underlineStyle, in: range) { value, _, _ in
            if value != nil {
                hasUnderline = true
            }
        }

        if hasUnderline {
            mutableAttrString.removeAttribute(.underlineStyle, range: range)
        } else {
            mutableAttrString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }

        textView.attributedText = mutableAttrString
        textView.selectedRange = range
    }

    private func insertBullet() {
        guard let textView = textView else { return }

        let currentText = textView.text ?? ""
        let selectedRange = textView.selectedRange

        // Find the start of the current line
        let nsString = currentText as NSString
        let lineRange = nsString.lineRange(for: NSRange(location: selectedRange.location, length: 0))

        // Insert bullet at the start of the line
        let mutableAttrString = NSMutableAttributedString(attributedString: textView.attributedText)
        let bulletString = NSAttributedString(string: "• ", attributes: textView.typingAttributes)

        mutableAttrString.insert(bulletString, at: lineRange.location)
        textView.attributedText = mutableAttrString

        // Move cursor after bullet
        textView.selectedRange = NSRange(location: selectedRange.location + 2, length: 0)
    }

    private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, in textView: UITextView) {
        let range = textView.selectedRange

        guard range.length > 0 else {
            // Toggle for typing attributes
            var typingAttributes = textView.typingAttributes
            if let font = typingAttributes[.font] as? UIFont {
                let newFont = toggleFontTrait(font, trait: trait)
                typingAttributes[.font] = newFont
                textView.typingAttributes = typingAttributes
            }
            return
        }

        let mutableAttrString = NSMutableAttributedString(attributedString: textView.attributedText)

        mutableAttrString.enumerateAttribute(.font, in: range) { value, subRange, _ in
            if let font = value as? UIFont {
                let newFont = toggleFontTrait(font, trait: trait)
                mutableAttrString.addAttribute(.font, value: newFont, range: subRange)
            }
        }

        textView.attributedText = mutableAttrString
        textView.selectedRange = range
    }

    private func toggleFontTrait(_ font: UIFont, trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traits = font.fontDescriptor.symbolicTraits

        if traits.contains(trait) {
            traits.remove(trait)
        } else {
            traits.insert(trait)
        }

        if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: newDescriptor, size: font.pointSize)
        }

        return font
    }
}
