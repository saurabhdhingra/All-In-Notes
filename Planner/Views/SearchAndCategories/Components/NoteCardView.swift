//
//  NoteCardView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 13/06/25.
//

import SwiftUI
import UIKit

struct NoteCardView: View {
    let note : Note
    let height : CGFloat
    let lineLimit : Int
    
    var body: some View {
        if #available(iOS 26.0, *) {
            NavigationLink(destination: NoteDetailView(note: note)) {
                VStack(alignment: .leading, spacing: 6){
                    Text(note.title)
                        .font(.headline)

                    Text(note.plainTextContent)
                        .font(.body)
                        .lineLimit(lineLimit)

                    if let firstImageData = note.previewImageData, let uiImage = UIImage(data: firstImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight:  height,  alignment: .leading)
                .background(Color.stableNoteColor(id: note.id))
                .cornerRadius(20)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    let note = Note(
        title: "Todo",
        lastUpdated: Date(),
        category: "Personal",
        blocks: [
            ContentBlock.text(order: 0, content: "- Buy Milk\n- Buy Bread\n- Code in Swift\n- Call Sakshi")
        ]
    )

    return NoteCardView(
        note: note,
        height: 100,
        lineLimit: 4
    )
}

