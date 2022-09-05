//
//  KvgStrokesView.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/29/22.
//

import SwiftUI

struct KvgStrokesView: View {
    var strokes: [GlyphStroke]
    var viewport: CGRect
    var isAnimated: Bool
    var color: Color = .black
    var scale = 1.0

    var body: some View {
        ZStack {
            ForEach(strokes.indices, id: \.self) { i in
                let stroke = strokes[i]
                StrokeView(id: i,
                           viewport: viewport,
                           stroke: stroke,
                           animated: isAnimated,
                           color: color,
                           style: .init(lineWidth: 4 * scale))
            }
        }
    }
}

struct KvgStrokesWrapperView: View {
    var strokes = [makeGlyphStroke()]
    var vp: CGRect = CGRect(x: 0, y: 0, width: 109, height: 2)
    @State var animated = true

    var body: some View {
        GeometryReader { geom in
            VStack {
                HStack {
                    KvgStrokesView(strokes: strokes, viewport: vp, isAnimated: animated)
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

struct KvgStrokesView_Previews: PreviewProvider {
    static var previews: some View {
        KvgStrokesWrapperView()
    }
}

