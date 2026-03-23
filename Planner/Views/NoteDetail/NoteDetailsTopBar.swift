//
//  NoteDetailsTopBar.swift
//  Planner
//
//  Created by Saurabh Dhingra on 15/06/25.
//

import SwiftUI

struct NoteDetailsTopBar: View {
    @Binding var selectedCategory: String
    let categories: [String]
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack){
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Spacer()
            Picker("", selection: $selectedCategory){
                ForEach(categories, id: \.self) {
                    Text($0)
                        .foregroundColor(.primary)
                        
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.15))
            .clipShape(Capsule())
            
            Spacer()
            
            Menu {
                Button("Duplicate", action: {})
                Button("Share", action: {})
                Button("Delete", action: {})
            } label : {
                Image(systemName: "chevron_down")
                    .rotationEffect(.degrees(90))
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

