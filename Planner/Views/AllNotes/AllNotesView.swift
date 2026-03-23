//
//  AllNotesView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 09/06/25.
//

import SwiftUI

struct AllNotesView: View {
    // 1. A state variable to control the visibility/position
    @State private var isCardVisible: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ZStack {
                    Text("All-in-Notes")
                        .font(.system(size: 40, design: .default))
                        .fontWeight(.bold)
                    TripleArchView().offset(x: 145, y: 25)
                }
                
                Text(
                    "Start turning thoughts into action with\na smart, simple note-taking experience."
                )
                .font(.system(size: 18))
                .foregroundStyle(.gray)
                
                NavigationLink(destination: SearchCategoriesView()) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.black))
                        .shadow(radius: 4)
                }
                
                ZStack {
                    DesignNoteCardView(title: "Work", color: Color("NoteCardYellow"), dColor: .yellow)
                    // Apply offset and animation to each card
                        .offset(y: isCardVisible ? 0 : 500)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: isCardVisible)
                    
                    CursiveELoopView().offset(x: -105, y: -30).rotationEffect(.degrees(10))
                    
                    DesignNoteCardView(title: "Clean Up", color: Color("NoteCardPink"), dColor: .pink)
                    
                        .offset(y: isCardVisible ? 150 : 1000)
                        .rotationEffect(.degrees(0.5))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: isCardVisible)
                    
                    DesignNoteCardView(title: "Meeting", color: Color("NoteCardBlue"), dColor: .blue)
                    
                        .offset(y: isCardVisible ? 300 : 1000)
                        .rotationEffect(.degrees(1))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.6), value: isCardVisible)
                    
                    DesignNoteCardView(title: "Drink coffee", color: Color("NoteCardGreen"), dColor: .green)
                    
                        .offset(y: isCardVisible ? 450: 1000)
                        .rotationEffect(.degrees(1.5))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.8), value: isCardVisible)
                }
                .onAppear {
                    // 4. Trigger the animation when the view appears
                    isCardVisible = true
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    AllNotesView()
        .modelContainer(for : Note.self, inMemory: true)
}
