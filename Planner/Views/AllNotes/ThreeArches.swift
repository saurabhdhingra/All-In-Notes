//
//  ThreeArches.swift
//  Planner
//
//  Created by Saurabh Dhingra on 30/06/25.
//
import SwiftUI

struct LeftAnchoredArch: Shape {
    let radius: CGFloat
    let offsetFromCenter: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Center of arch
        let archCenter = CGPoint(x: center.x + offsetFromCenter, y: center.y)

        // Start point on left side
        let startAngle: Angle = .degrees(210)
        let endAngle: Angle = .degrees(255)

        var path = Path()
        path.addArc(center: archCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

struct TripleArchView: View {
    let archColor = Color(red: 87/255, green: 203/255, blue: 251/255)

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<3) { i in
                LeftAnchoredArch(radius: 60, offsetFromCenter: getArchOffset(for: i))
                    .stroke(archColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(Double(i * 15 )))
                    .frame(width: 60, height: 15)
            }
        }
    }
}

func getArchOffset(for index: Int) -> CGFloat {
    let oneDegree = Double.pi/180
    
    return  30 * (sin(CGFloat(oneDegree * Double((60 - index*15)))))
}

#Preview {
    TripleArchView()
}
