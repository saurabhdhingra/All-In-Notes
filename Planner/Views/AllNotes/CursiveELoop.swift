//
//  CursiveLoop.swift
//  Planner
//
//  Created by Saurabh Dhingra on 30/06/25.
//

import SwiftUI

struct CursiveELoop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()


               // Adjusted control points based on your image
               let start = CGPoint(x: rect.minX - 40, y: rect.midY)
               let loopEnd1 = CGPoint(x: rect.maxX, y: rect.midY)
               let loopEnd2 = CGPoint(x: rect.maxX - 60 , y: rect.midY)
               let exit = CGPoint(x: rect.maxX, y: rect.maxY)

               path.move(to: start)

               // Sweep down and up into the loop
               path.addCurve(to: loopEnd1,
                             control1: CGPoint(x: rect.midX - 60, y: rect.midY + 100),
                             control2: CGPoint(x: rect.midX + 80, y: rect.midY + 100))

               // Loop back down and exit
               path.addCurve(to: loopEnd2,
                             control1: CGPoint(x: rect.maxX - 10, y: rect.midY - 60),
                             control2: CGPoint(x: rect.maxX - 40, y: rect.midY - 75))
        
        path.addCurve(to: exit,
                      control1: CGPoint(x: rect.maxX - 70, y: rect.midY + 50),
                      control2: CGPoint(x: rect.maxX - 20, y: rect.midY + 110))

               return path
    }
}


struct CursiveELoopView: View {
    @State private var trimValue: CGFloat = 0.0
    
    var body: some View {
        CursiveELoop()
            .trim(from: 0, to: trimValue)
            .stroke(Color.yellow, lineWidth: 10)
            .frame(width: 140, height: 260)
            .onAppear {
                            // 3. Trigger the animation when the view appears
                            withAnimation(.easeIn(duration: 2.0)) {
                                // Animate the trim value from 0 to 1
                                trimValue = 1.0
                            }
                        }
    }
}

#Preview {
    CursiveELoopView()
}
