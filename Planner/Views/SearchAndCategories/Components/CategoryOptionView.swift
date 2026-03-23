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
    var tagColor: Color? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let color = tagColor {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }

            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? (tagColor ?? Color.black) : Color.gray.opacity(0.2))
        )
        .foregroundColor(isSelected ? .white : .primary)
    }
}

#Preview {
    VStack(spacing: 12) {
        CategoryOptionView(title: "All", isSelected: true)
        CategoryOptionView(title: "Work", isSelected: false, tagColor: .blue)
        CategoryOptionView(title: "Personal", isSelected: true, tagColor: .green)
    }
}
