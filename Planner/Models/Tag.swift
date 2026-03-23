//
//  Tag.swift
//  Planner
//
//  Created by Saurabh Dhingra on 23/03/26.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

@Model
class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = Tag.randomColorHex(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
    }

    // MARK: - Color Helpers

    var color: Color {
        Color(hex: colorHex) ?? .gray
    }

    static func randomColorHex() -> String {
        let colors = [
            "#FF6B6B", // Coral Red
            "#4ECDC4", // Teal
            "#45B7D1", // Sky Blue
            "#96CEB4", // Sage Green
            "#FFEAA7", // Soft Yellow
            "#DDA0DD", // Plum
            "#98D8C8", // Mint
            "#F7DC6F", // Mustard
            "#BB8FCE", // Lavender
            "#85C1E9", // Light Blue
            "#F8B500", // Golden
            "#FF8C69", // Salmon
        ]
        return colors.randomElement() ?? "#4ECDC4"
    }

    // MARK: - Default Tags

    static var defaultTags: [Tag] {
        [
            Tag(name: "Work", colorHex: "#45B7D1"),
            Tag(name: "Personal", colorHex: "#96CEB4"),
            Tag(name: "Lists", colorHex: "#FFEAA7")
        ]
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
