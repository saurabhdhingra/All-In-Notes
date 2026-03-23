//
//  SearchCategoriesView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 09/06/25.
//

import SwiftUI
import SwiftData
import UIKit

struct SearchCategoriesView: View {
    @State private var isDrawerOpen = false
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var createNewNoteNavigation: Bool = false
    @State private var showTagsView: Bool = false
    @State private var showAboutView: Bool = false
    @Environment(\.modelContext) private var context
    @State private var selectedNote: Note?
    @Query(sort: \Note.lastUpdated, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Tag.createdAt) private var tags: [Tag]
    
    private var categories: [String] {
        // Use tags from the database, fallback to notes' categories for backward compatibility
        if !tags.isEmpty {
            return ["All"] + tags.map { $0.name }
        }
        let unique = Set(allNotes.map { $0.category }.filter { !$0.isEmpty })
        return ["All"] + Array(unique).sorted()
    }
    
    private var filteredNotes: [Note] {
        allNotes.filter { note in
            let matchesCategory = selectedCategory == "All" || note.category == selectedCategory
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return matchesCategory
            }
            let query = searchText.lowercased()
            let inTitle = note.title.lowercased().contains(query)
            return matchesCategory && inTitle
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    TopAppBar(isDrawerOpen: $isDrawerOpen, onAddTapped: {
                        let newNote = Note(title: "", lastUpdated: Date(), category: "Work")
                        context.insert(newNote)
                        selectedNote = newNote
                        createNewNoteNavigation = true
                    })
                    SearchField(text: $searchText)
                    CategoryOptions(categories: categories, tags: tags, selectedCategory: $selectedCategory)
                    NotesGridView(notes: filteredNotes)
                }


                // Drawer overlay and content
                if isDrawerOpen {
                    // Dimmed background overlay
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isDrawerOpen = false
                            }
                        }
                        .zIndex(1)
                }

                // Drawer - always in view hierarchy for smooth animation
                DrawerView(
                    onTagsTapped: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isDrawerOpen = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showTagsView = true
                        }
                    },
                    onAboutTapped: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isDrawerOpen = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showAboutView = true
                        }
                    },
                    onCloseTapped: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isDrawerOpen = false
                        }
                    }
                )
                .offset(x: isDrawerOpen ? 0 : -UIScreen.main.bounds.width)
                .zIndex(2)
            }
            .navigationDestination(isPresented: $createNewNoteNavigation) {
                if #available(iOS 26.0, *), let note = selectedNote {
                    NoteDetailView(note: note)
                } else {
                    Text("Note editor requires iOS 26.0 or later")
                }
            }
            .navigationTitle("Notes")
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showTagsView) {
                TagsView()
            }
            .fullScreenCover(isPresented: $showAboutView) {
                AboutAppView()
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isDrawerOpen)
        }
    }
}

struct CategoryOptions: View {
    let categories: [String]
    let tags: [Tag]
    @Binding var selectedCategory: String

    private func colorForCategory(_ category: String) -> Color? {
        guard category != "All" else { return nil }
        return tags.first { $0.name == category }?.color
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryOptionView(
                        title: category,
                        isSelected: selectedCategory == category,
                        tagColor: colorForCategory(category)
                    )
                    .onTapGesture {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SearchField: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName : "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .foregroundColor(.primary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1).padding(.horizontal, 12))
    }
}

struct NotesGridView: View{
    let notes: [Note]

    private var sections: [[Note]] {
        var result: [[Note]] = []
        var index = 0
        while index < notes.count {
            let end = min(index + 3, notes.count)
            let chunk = Array(notes[index..<end])
            if chunk.count == 3 {
                result.append(chunk)
            } else if chunk.count == 2 {
                // pad with an empty placeholder to keep layout balanced without duplication
                // We'll render only the available notes in the section by customizing NoteGridSection usage here.
                result.append(chunk)
            } else if chunk.count == 1 {
                result.append(chunk)
            }
            index += 3
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12){
                ForEach(sections.indices, id: \.self) { index in
                    let section = sections[index]
                    if section.count == 3 {
                        NoteGridSection(notes: section, isLeftStacked: index % 2 == 0)
                            .padding(.horizontal)
                    } else if section.count == 2 {
                        HStack(spacing: 12) {
                            NoteCardView(note: section[0], height: 170, lineLimit: 4)
                            NoteCardView(note: section[1], height: 170, lineLimit: 4)
                        }
                        .frame(height: 170)
                        .padding(.horizontal)
                    } else if section.count == 1 {
                        HStack(spacing: 12) {
                            NoteCardView(note: section[0], height: 170, lineLimit: 4)
                        }
                        .frame(height: 170)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
