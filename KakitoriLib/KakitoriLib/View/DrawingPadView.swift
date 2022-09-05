//
//  SwiftUIView.swift
//  
//
//  Created by Ansel Rognlie on 8/30/22.
//  based on: https://martinmitrevski.com/2019/07/20/developing-drawing-app-with-swiftui/
//  https://github.com/martinmitrevski/DrawingPadSwiftUI

import SwiftUI

public struct DrawingPadView: View {
    @ObservedObject var vm: DrawingPadViewModel

    public init(vm: DrawingPadViewModel) {
        self.vm = vm
    }

    private func add(drawing: Drawing, toPath path: inout Path) {
        path.addPath(drawing.interpolateCGPointsWithCatmullRom(alpha: 1.0))
    }

    private func isPoint(_ point: CGPoint, in bounds: CGSize) -> Bool {
        return point.x >= 0 && point.y >= 0
            && point.x <= bounds.width && point.y <= bounds.height
    }

    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                for drawing in vm.drawings {
                    self.add(drawing: drawing, toPath: &path)
                }
                self.add(drawing: vm.currentDrawing, toPath: &path)
            }
            .stroke(style: .init(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
            .background(Color(white: 0.95))
            .gesture(
                DragGesture(minimumDistance: 0.05)
                    .onChanged({ (value) in
//                        print("dragging: \(vm.isDragging)")
                        let currentPoint = value.location
                        if isPoint(currentPoint, in: geometry.size) {
                            vm.currentDrawing.points.append(currentPoint)
                        }
                    })
                    .onEnded({ (value) in
                        vm.drawings.append(vm.currentDrawing)
                        vm.currentDrawing = Drawing()
                    })
            )
        }
    }
}

struct DrawingPadPreviewView: View {
    @StateObject var vm = DrawingPadViewModel()

    var body: some View {
        VStack {
            DrawingPadView(vm: vm)
            Spacer()
        }
    }
}

struct DrawingPadView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPadPreviewView()
    }
}
