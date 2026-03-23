//
//  FloatingBottomBarView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 09/06/25.
//

import SwiftUI

struct FloatingBottomBarView: View {
    let barHeight: CGFloat = 64
    let floatingRadius: CGFloat = 32

    var body: some View {
        ZStack {
            // Background pill with cutout
            BottomBarShape(cutoutRadius: floatingRadius + 10)
                    
                    .foregroundColor(Color(red: 35/255, green: 35/255, blue: 46/255))
                    .frame(width: 300, height: barHeight)
                    .shadow(radius: 8)

                // Icon buttons
            HStack(spacing: 12) {
                    BottomBarButton(systemName: "house.fill") {}
                    BottomBarButton(systemName: "magnifyingglass") {}
                    Spacer().frame(width: (floatingRadius * 2) + 12)
                    BottomBarButton(systemName: "bookmark.fill") {}
                    BottomBarButton(systemName: "gearshape.fill") {}
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 16)
        }
}

struct BottomBarShape: Shape {
    let cutoutRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Full rounded rect
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: rect.height / 2, height: rect.height / 2))

        // Cutout circle path
        let center = CGPoint(x: rect.midX, y: rect.minY)
        let lCenter = CGPoint(x: rect.midX - cutoutRadius * 11/10   , y: rect.minY + cutoutRadius / 10)
        let rCenter = CGPoint(x: rect.midX + cutoutRadius * 11/10, y: rect.minY + cutoutRadius/10)
        let cutout = Path { p in
            p.addArc(center: lCenter, radius: cutoutRadius/10, startAngle: .degrees(270), endAngle: .zero, clockwise: false)
            
            p.addArc(center: center, radius: cutoutRadius, startAngle: .degrees(180), endAngle: .zero, clockwise: true)
            
            p.addArc(center: rCenter, radius: cutoutRadius/10, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
   
        }

        // Subtract cutout
        path.addPath(cutout, transform: .identity)

        return path
    }
}

struct BottomBarButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.gray)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
    }
}

#Preview {
    FloatingBottomBarView()
}
