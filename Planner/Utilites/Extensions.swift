//
//  Extensions.swift
//  Planner
//
//  Created by Saurabh Dhingra on 24/09/25.
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let notesDidChange = Notification.Name("notesDidChange")
}

extension Color {
    static func stableNoteColor(id: UUID) -> Color {
        // Hash UUID into H,S,L with decent contrast
        let hash = id.uuidString.unicodeScalars.map { UInt32($0.value) }.reduce(0, ^)
        let hue = Double(hash % 360) / 360.0
        // Fix saturation and lightness for contrast against system background
        let saturation: Double = 0.45
        let lightness: Double = 0.88
        return Color(hue: hue, saturation: saturation, brightness: lightness)
    }
}


extension DateFormatter {
    static var mediumDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
