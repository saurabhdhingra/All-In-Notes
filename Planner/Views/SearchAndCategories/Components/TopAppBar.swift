//
//  TopAppBar.swift
//  Planner
//
//  Created by Saurabh Dhingra on 11/06/25.
//

import SwiftUI

struct TopAppBar: View {
    @Binding var isDrawerOpen: Bool
    
    var body: some View {
        HStack{
            Button(action: {
                isDrawerOpen.toggle()
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
            
            Image("profile_pic")
                .resizable().resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            
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
