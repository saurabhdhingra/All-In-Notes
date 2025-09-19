//
//  NoteContentBlockType.swift
//  Planner
//
//  Created by Saurabh Dhingra on 15/06/25.
//

import Foundation

enum NoteContentBlock: Identifiable {
    case plain(String)
    case highlighted(String)
    case image(String)
    
    var id: UUID {
        UUID()
    }
}
