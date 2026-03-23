//
//  NoteGridSection.swift
//  Planner
//
//  Created by Saurabh Dhingra on 13/06/25.
//

import SwiftUI

struct NoteGridSection: View {
    let notes: [Note]
    let isLeftStacked: Bool
    
    var body: some View {
        HStack(spacing: 12){
            if isLeftStacked {
                twoStackedNotes(notes[0], notes[1])
                largeNote(notes[2])
            }else{
                largeNote(notes[2])
                twoStackedNotes(notes[0], notes[1])
            }
        }
        .frame(height: 352)
    }
    
    func twoStackedNotes(_ top: Note, _ bottom: Note) -> some View {
        VStack(spacing: 12) {
            NoteCardView(note: top, height : 170, lineLimit : 4)
            NoteCardView(note: bottom, height : 170, lineLimit: 4)
        }
    }
    
    func largeNote(_ note: Note) -> some View {
        NoteCardView(note: note, height: 352, lineLimit : 12)
      
    }
}

#Preview {
    NoteGridSection(notes: [
        Note(title: "Todo", content: "- Buy Milk\n- Buy Bread\n- Code in Swift\n- Call Sakshi", lastUpdated: Date(), category: "Personal", imageData: nil),
        Note(title: "Quote", content: "Creativity is intelligence having fun.", lastUpdated: Date(), category: "Inspiration", imageData : nil),
        Note(title: "Sketch", content: "A sketch from ideation.", lastUpdated: Date(), category: "Design", imageData : nil)
        
    ], isLeftStacked: false)
}
