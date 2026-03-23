//
//  ActiveTextViewManager.swift
//  Planner
//
//  Created by Claude on 21/03/26.
//

import SwiftUI
import UIKit

/// Manages the currently active UITextView for rich text formatting
/// This allows the formatting toolbar to apply styles to the focused text view
@Observable
class ActiveTextViewManager {
    weak var activeTextView: UITextView?

    // MARK: - Formatting Actions

    func toggleBold() {
        guard let textView = activeTextView else { return }
        toggleTrait(.traitBold, in: textView)
    }

    func toggleItalic() {
        guard let textView = activeTextView else { return }
        toggleTrait(.traitItalic, in: textView)
    }

    func toggleUnderline() {
        guard let textView = activeTextView else { return }

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

        // Notify delegate of change to trigger save
        notifyTextChange(textView)
    }

    func insertBullet() {
        guard let textView = activeTextView else { return }

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

        // Notify delegate of change to trigger save
        notifyTextChange(textView)
    }

    // MARK: - Change Notification

    /// Notifies the text view's delegate that content changed, triggering save
    private func notifyTextChange(_ textView: UITextView) {
        textView.delegate?.textViewDidChange?(textView)
    }

    // MARK: - Private Helpers

    private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, in textView: UITextView) {
        let range = textView.selectedRange

        guard range.length > 0 else {
            // Toggle for typing attributes (no need to save - affects future typing only)
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

        // Notify delegate of change to trigger save
        notifyTextChange(textView)
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
