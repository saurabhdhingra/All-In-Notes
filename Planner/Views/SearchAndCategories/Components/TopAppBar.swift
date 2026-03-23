//
//  TopAppBar.swift
//  Planner
//
//  Created by Saurabh Dhingra on 11/06/25.
//

import SwiftUI

struct TopAppBar: View {
    @Binding var isDrawerOpen: Bool
    var onAddTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack{
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isDrawerOpen.toggle()
                }
            }){
                Image(systemName: "line.horizontal.3")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Text("My Notes")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.leading, 8)
            
            Spacer()
            Button(action: { onAddTapped?() }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).ignoresSafeArea(edges: .top))
    }
}

#Preview {
    StatefulPreviewWrapper(false) { binding in
        TopAppBar(isDrawerOpen: binding)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> Content

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}



struct DrawerView: View {
    var onTagsTapped: (() -> Void)? = nil
    var onAboutTapped: (() -> Void)? = nil
    var onCloseTapped: (() -> Void)? = nil

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Drawer content
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)

                            Spacer()

                            Button(action: { onCloseTapped?() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text("Planner")
                            .font(.title.weight(.bold))
                            .foregroundColor(.primary)

                        Text("Organize your thoughts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 24)

                    Divider()
                        .padding(.horizontal, 24)

                    // MARK: - Menu Options
                    VStack(alignment: .leading, spacing: 8) {
                        DrawerMenuItem(
                            icon: "tag.fill",
                            title: "Manage Tags",
                            subtitle: "Create and organize tags",
                            action: { onTagsTapped?() }
                        )

                        DrawerMenuItem(
                            icon: "info.circle.fill",
                            title: "About",
                            subtitle: "About the developer",
                            action: { onAboutTapped?() }
                        )
                    }
                    .padding(.vertical, 16)

                    Spacer()

                    // MARK: - Footer
                    VStack(spacing: 12) {
                        Divider()

                        HStack(spacing: 4) {
                            Text("Made with")
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("in India")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)

                        Text("v1.0.0")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .frame(width: geometry.size.width * 0.75)
                .frame(maxHeight: .infinity)
                .background(Color(.systemBackground))

                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Drawer Menu Item
struct DrawerMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct DrawerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()

            DrawerView()
        }
    }
}
