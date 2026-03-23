//
//  TagsView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 23/03/26.
//

import SwiftUI
import SwiftData

struct TagsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.createdAt, order: .reverse) private var tags: [Tag]

    @State private var showingAddTag = false
    @State private var tagToEdit: Tag?
    @State private var showingDeleteAlert = false
    @State private var tagToDelete: Tag?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    TagsHeaderView(
                        onBackTapped: { dismiss() },
                        onAddTapped: { showingAddTag = true }
                    )

                    if tags.isEmpty {
                        EmptyTagsView(onAddTapped: { showingAddTag = true })
                    } else {
                        TagsListView(
                            tags: tags,
                            onEdit: { tag in tagToEdit = tag },
                            onDelete: { tag in
                                tagToDelete = tag
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTag) {
                AddEditTagSheet(mode: .add) { name, colorHex in
                    let newTag = Tag(name: name, colorHex: colorHex)
                    context.insert(newTag)
                }
            }
            .sheet(item: $tagToEdit) { tag in
                AddEditTagSheet(mode: .edit(tag)) { name, colorHex in
                    tag.name = name
                    tag.colorHex = colorHex
                }
            }
            .alert("Delete Tag", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    tagToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let tag = tagToDelete {
                        context.delete(tag)
                        tagToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this tag? This action cannot be undone.")
            }
            .onAppear {
                seedDefaultTagsIfNeeded()
            }
        }
    }

    private func seedDefaultTagsIfNeeded() {
        guard tags.isEmpty else { return }
        for tag in Tag.defaultTags {
            context.insert(tag)
        }
    }
}

// MARK: - Header View

struct TagsHeaderView: View {
    var onBackTapped: () -> Void
    var onAddTapped: () -> Void

    var body: some View {
        HStack {
            Button(action: onBackTapped) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }

            Text("Manage Tags")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.leading, 8)

            Spacer()

            Button(action: onAddTapped) {
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

// MARK: - Empty State View

struct EmptyTagsView: View {
    var onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "tag.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Tags Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Create tags to organize your notes better")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onAddTapped) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Tag")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                )
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}

// MARK: - Tags List View

struct TagsListView: View {
    let tags: [Tag]
    var onEdit: (Tag) -> Void
    var onDelete: (Tag) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(tags) { tag in
                    TagRowView(
                        tag: tag,
                        onEdit: { onEdit(tag) },
                        onDelete: { onDelete(tag) }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Tag Row View

struct TagRowView: View {
    let tag: Tag
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Color indicator
            Circle()
                .fill(tag.color)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )

            // Tag name
            Text(tag.name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue.opacity(0.8))
            }

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(tag.color.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tag.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Add/Edit Tag Sheet

enum TagSheetMode: Identifiable {
    case add
    case edit(Tag)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let tag): return tag.id.uuidString
        }
    }
}

struct AddEditTagSheet: View {
    let mode: TagSheetMode
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var tagName: String = ""
    @State private var selectedColorHex: String = Tag.randomColorHex()

    private let colorOptions = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F",
        "#BB8FCE", "#85C1E9", "#F8B500", "#FF8C69"
    ]

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var isValid: Bool {
        !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Tag Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextField("Enter tag name", text: $tagName)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Color Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tag Color")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            ColorOptionView(
                                colorHex: colorHex,
                                isSelected: selectedColorHex == colorHex,
                                onTap: { selectedColorHex = colorHex }
                            )
                        }
                    }
                }

                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Spacer()
                        TagPreviewView(
                            name: tagName.isEmpty ? "Tag Name" : tagName,
                            color: Color(hex: selectedColorHex) ?? .gray
                        )
                        Spacer()
                    }
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle(isEditing ? "Edit Tag" : "New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(tagName.trimmingCharacters(in: .whitespacesAndNewlines), selectedColorHex)
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if case .edit(let tag) = mode {
                    tagName = tag.name
                    selectedColorHex = tag.colorHex
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Color Option View

struct ColorOptionView: View {
    let colorHex: String
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(Color(hex: colorHex) ?? .gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0)
                )
        }
    }
}

// MARK: - Tag Preview View

struct TagPreviewView: View {
    let name: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(name)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    TagsView()
        .modelContainer(for: [Tag.self])
}
