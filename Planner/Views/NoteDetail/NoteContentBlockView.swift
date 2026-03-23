//
//  NoteContentBlockView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 09/06/25.
//

import SwiftUI

struct NoteContentBlockView: View {
    let content: NoteContentBlock
    
    var body: some View {
        switch content {
        case .plain(let text):
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.vertical, 4)
            
        case .highlighted(let text):
            HStack(alignment: .top, spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.indigo)
                    .frame(width: 4)
            Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 4)
            
        case .image(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .padding(.vertical, 8)
        }
    }
}

