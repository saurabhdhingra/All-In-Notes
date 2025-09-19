//
//  CategoryOptionView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 10/06/25.
//

import SwiftUI

struct CategoryOptionView: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.bold)
            .padding(.horizontal, 16)
        
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.black : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
    }
}

#Preview {
    CategoryOptionView(title: "Work", isSelected: true)
}
