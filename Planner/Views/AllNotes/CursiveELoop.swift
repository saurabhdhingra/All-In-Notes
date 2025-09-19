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

        // Starting point at left-middle
        let startX = rect.minX + 20
        let startY = rect.midY

        path.move(to: CGPoint(x: startX, y: startY))

        // Draw a loop resembling a cursive "e"
        path.addCurve(
            to: CGPoint(x: startX + 80, y: startY), // end at right
            control1: CGPoint(x: startX + 30, y: startY - 40),
            control2: CGPoint(x: startX + 50, y: startY + 40)
        )

        path.addCurve(
            to: CGPoint(x: startX + 40, y: startY - 10), // tail
            control1: CGPoint(x: startX + 90, y: startY - 30),
            control2: CGPoint(x: startX + 60, y: startY - 40)
        )

        return path
    }
}
