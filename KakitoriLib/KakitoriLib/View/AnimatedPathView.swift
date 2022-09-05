//
//  AnimatedPathView.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/21/22.
//

import SwiftUI

struct MyLines: View {
    var height: CGFloat
    var width: CGFloat

    @State private var percentage: CGFloat = .zero
        var body: some View {

            // ZStack {         // as for me, looks better w/o stack which tighten path
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height/2))
                    path.addLine(to: CGPoint(x: width/2, y: height))
                    path.addLine(to: CGPoint(x: width, y: 0))
                }
                .trim(from: 0, to: percentage) // << breaks path by parts, animatable
                .stroke(Color.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .animation(.easeOut(duration: 2.0).repeatForever(autoreverses: false), value: percentage) // << animate
                .onAppear {
                    self.percentage = 1.0 // << activates animation for 0 to the end
                }

            //}
        }

    @State var animationAmount = 0.0

//    var body: some View {
//        Button("Tap Me") {
//            // animationAmount += 1
//        }
//        .padding(50)
//        .background(.red)
//        .foregroundColor(.white)
//        .clipShape(Circle())
//        .overlay(
//            Circle()
//                .stroke(.red)
//                .scaleEffect(animationAmount)
//                .opacity(2 - animationAmount)
//                .animation(
//                    .easeInOut(duration: 1)
//                    .repeatForever(autoreverses: false),
//                    value: animationAmount
//                )
//        )
//        .onAppear {
//            animationAmount = 2
//        }
//    }

}

struct AnimatedPathView: View {
    var body: some View {
        GeometryReader { geo in
            MyLines(height: geo.size.height, width: geo.size.width)
        }
    }
}

struct AnimatedPathView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedPathView()
    }
}
