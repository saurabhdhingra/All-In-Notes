//
//  PlannerApp.swift
//  Planner
//
//  Created by Saurabh Dhingra on 09/06/25.
//

import SwiftUI
import SwiftData

@main
struct PlannerApp: App {

    var body: some Scene {
        WindowGroup {
            AllNotesView()
        }
        .modelContainer(for: [
            Note.self,
            ContentBlock.self,
            MediaAttachment.self,
            Tag.self
        ])
    }
}
