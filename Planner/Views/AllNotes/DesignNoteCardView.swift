//
//  NoteCardView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 09/06/25.
//

import SwiftUI

struct DesignNoteCardView: View {
    let title: String
    let color: Color
    let dColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Circle()
                    .fill(dColor)
                    .frame(width: 30, height: 30)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(color))
        .frame(width: 380, height: 200)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    DesignNoteCardView(
        title: "Title",
        color: Color.pink.opacity(0.5),
        dColor: Color.pink
    ).padding()
}
