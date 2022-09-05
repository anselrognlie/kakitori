//
//  StrokeShape.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/28/22.
//

import Foundation
import CoreGraphics
import SwiftUI

let kStrokeTime = 0.25
let kBaseFont = 18.0

struct StrokeView: View {

    var viewport: CGRect
    var stroke: GlyphStroke
    var animated: Bool
    var style: StrokeStyle
    var id: Int
    var color: Color

    internal init(id: Int, viewport: CGRect, stroke: GlyphStroke, animated: Bool, color: Color = .black, style: StrokeStyle = .init()) {
        self.viewport = viewport
        self.stroke = stroke
        self.animated = animated
        self.id = id
        self.color = color

        var style = style
        style.lineCap = .round
        style.lineJoin = .round
        self.style = style
    }

    var body: some View {
        if animated {
            AnimatedInternalStrokeView(id: id, viewport: viewport, stroke: stroke, style: style)
                .foregroundColor(color)
        } else {
            InternalStrokeView(viewport: viewport, stroke: stroke, style: style)
                .foregroundColor(color)
            //            Text("Stroke")
        }
    }
}

struct InternalStrokeView: View {

    var viewport: CGRect
    var stroke: GlyphStroke
    var style: StrokeStyle

    internal init(viewport: CGRect, stroke: GlyphStroke, style: StrokeStyle = .init()) {
        self.viewport = viewport
        self.stroke = stroke

        var style = style
        style.lineCap = .round
        style.lineJoin = .round
        self.style = style
    }

    var body: some View {
        GeometryReader { geom in
            Path { path in
                path.addPath(buildPath(stroke: stroke, size: geom.size, viewport: viewport))
            }
            .stroke(style: style)
        }
    }
}


struct AnimatedInternalStrokeView: View {

    var viewport: CGRect
    var stroke: GlyphStroke
    var style: StrokeStyle
    var id: Int

    @State private(set) var drawTo: Double

    internal init(id: Int, viewport: CGRect, stroke: GlyphStroke, style: StrokeStyle = .init()) {
        self.viewport = viewport
        self.stroke = stroke
        self.id = id

        var style = style
        style.lineCap = .round
        style.lineJoin = .round
        self.style = style

        drawTo = 0
    }

    var body: some View {
        GeometryReader { geom in
            Path { path in
                path.addPath(buildPath(stroke: stroke, size: geom.size, viewport: viewport))
            }
            .trim(from: 0, to: drawTo)
            .stroke(style: style)
            .animation(.easeOut(duration: kStrokeTime).delay(kStrokeTime * Double(id)), value: drawTo)
        }
        .onAppear {
            drawTo = 1.0
        }
    }
}

func buildPath(stroke: GlyphStroke, size: CGSize, viewport: CGRect) -> Path {
    let hScale = size.width / viewport.width
    let vScale = size.height / viewport.height
    let scale = min(hScale, vScale)

    let builder = ShapePathBuilder(scale: scale)
    for part in stroke.strokeParts {
        part.toPath(pathBuilder: builder)
    }

    return builder.path
}

struct StrokeNumberView: View {
    var text: String
    var transform: CGAffineTransform
    var id: Int
    var scale: Double = 1.0
    var animated: Bool

    var body: some View {
        if animated {
            InternalAnimatedStrokeNumberView(text: text, transform: transform, id: id, scale: scale)
        } else {
            InternalStrokeNumberView(text: text, transform: transform, scale: scale)
        }
    }
}

struct InternalStrokeNumberView: View {

    var text: String
    var transform: CGAffineTransform
    var scale: Double = 1.0

    var body: some View {
        Text(text)
            .font(.system(size: kBaseFont * scale))
            .position(x: 0, y: 0)
            .transformEffect(transform)
            .foregroundColor(.gray)
    }
}

struct InternalAnimatedStrokeNumberView: View {

    var text: String
    var transform: CGAffineTransform
    var id: Int
    var scale: Double

    @State var visible: Bool

    internal init(text: String, transform: CGAffineTransform, id: Int, scale: Double = 1.0) {
        self.text = text
        self.transform = transform
        self.id = id
        self.scale = scale

        visible = false
    }

    var body: some View {
        Text(text)
            .font(.system(size: kBaseFont * scale))
            .opacity(visible ? 1.0 : 0.0)
            .position(x: 0, y: 0)
            .transformEffect(transform)
            .foregroundColor(.gray)
            .animation(.linear(duration: 0.01).delay(kStrokeTime * Double(id)), value: visible)
            .onAppear {
                visible = true
            }
    }
}

class ShapePathBuilder: PathBuilder {
    var path: Path
    let scale: Double
    var currentPoint: CGPoint = .zero
    var smoothControlPoint: CGPoint = .zero

    init(scale: Double) {
        self.scale = scale
        self.path = .init()
    }

    func addCurve(to: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        path.addCurve(to: to.scale(by: scale),
                      control1: controlPoint1.scale(by: scale),
                      control2: controlPoint2.scale(by: scale))
        smoothControlPoint = to + (to - controlPoint2)
        currentPoint = to
    }

    public func addSmoothCurve(to: CGPoint, controlPoint2: CGPoint) {
        path.addCurve(to: to.scale(by: scale),
                      control1: smoothControlPoint.scale(by: scale),
                      control2: controlPoint2.scale(by: scale))
        smoothControlPoint = to + (to - controlPoint2)
        currentPoint = to
    }

    func move(to: CGPoint) {
        path.move(to: to.scale(by: scale))
        currentPoint = to
    }
}

extension CGPoint {
    func scale(horizontal: Double, vertical: Double) -> CGPoint {
        let x = self.x * horizontal
        let y = self.y * vertical
        return CGPoint(x: x, y: y)
    }

    func scale(by: Double) -> CGPoint {
        let x = self.x * by
        let y = self.y * by
        return CGPoint(x: x, y: y)
    }
}

struct StrokeWrapperView: View {
    var gs: GlyphStroke = makeGlyphStroke()
    var vp: CGRect = CGRect(x: 0, y: 0, width: 109, height: 2)
    @State var animated = true

    var body: some View {
        GeometryReader { geom in
            VStack {
                HStack {
                    StrokeView(
                        id: 0,
                        viewport: vp,
                        stroke: gs,
                        animated: animated,
                        color: .gray,
                        style: .init(lineWidth: 20)
                    )
                }
                .frame(height: 10)
                .padding()

                Button {
                    animated = !animated
                    print(animated)
                } label: {
                    Text("Toggle")
                }
                Spacer()
            }
        }
    }

    static func makeGlyphStroke() -> GlyphStroke {
        let p0 = MoveStrokePart(id: 0, isRelative: false, x: 10, y: 1)
        let p1 = CurveStrokePart(id: 1, isRelative: true,
                                 xcp1: 0, ycp1: 0,
                                 xcp2: 89, ycp2: 0,
                                 x2: 89, y2: 0)

        return GlyphStroke(id: "stroke1", strokeParts: [p0, p1])
    }
}

struct StrokeView_Previews: PreviewProvider {
    static var previews: some View {
        StrokeWrapperView()
    }
}

