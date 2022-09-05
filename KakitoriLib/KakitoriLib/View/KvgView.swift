//
//  KvgView.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/21/22.
//

import SwiftUI

public struct KvgView: View {
    @ObservedObject var viewModel: KvgViewModel

    public init(viewModel: KvgViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geo in
            let minDim = minimumDimension(geo.size)

            ZStack {
                if let strokeData = viewModel.strokeData {

                    let scale = calculateScale(viewport: strokeData.viewport, size: geo.size)
                    let fontScale = 0.3

                    let strokes = KvgStrokesView(
                        strokes: strokeData.strokes,
                        viewport: strokeData.viewport,
                        isAnimated: false,
                        color: viewModel.isAnimated ?
                            grayColor() :
                            .black,
                        scale: scale)
                        .frame(width: minDim, height: minDim)

                    let drawnStrokes = strokes.drawingGroup()

                    let animStrokes = KvgStrokesView(
                        strokes: strokeData.strokes,
                        viewport: strokeData.viewport,
                        isAnimated: viewModel.isAnimated,
                        scale: scale)
                        .frame(width: minDim, height: minDim)

                    let drawnAnimStrokes = animStrokes.drawingGroup()

                    let labels = ZStack {
                        ForEach(strokeData.numbers.indices, id: \.self) { i in
                            let num = strokeData.numbers[i]
                            let transform = CGAffineTransform(
                                a: num.a, b: num.b,
                                c: num.c, d: num.d,
                                tx: num.e * scale, ty: num.f * scale)

                            StrokeNumberView(
                                text: num.text,
                                transform: transform,
                                id: i,
                                scale: scale * fontScale,
                                animated: viewModel.isAnimated)
                        }
                    }
                    .frame(width: minDim, height: minDim)

                    let glyph = HStack {
                        Text(strokeData.glyph)
                            .font(.custom(GlyphConfig.fontName, size: minimumDimension(geo.size) * 0.9))
                    }
                    .frame(width: minDim, height: minDim)


                    if viewModel.showDrawn {
                        if viewModel.isAnimated {
                            drawnStrokes
                            if !viewModel.isPending {
                                drawnAnimStrokes
                            }
                        } else {
                            drawnStrokes
                        }
                    }

                    if viewModel.showGlyph {
                        glyph
                    }

                    if viewModel.showLabels {
                        labels
                    }
                } else {
                    Text("Loading")
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

fileprivate func grayColor() -> Color {
    let brightness = 0.8
    return Color(red: brightness, green: brightness, blue: brightness)
}

func calculateScale(viewport: CGRect, size: CGSize) -> Double {
    let hScale = size.width / viewport.width
    let vScale = size.height / viewport.height
    return min(hScale, vScale)
}

func minimumDimension(_ size: CGSize) -> Double {
    return min(size.width, size.height)
}

struct KvgPreviewView: View {
    @StateObject var vm = KvgViewModel()

    var body: some View {
        VStack {
            KvgView(viewModel: vm)
            Spacer()
        }
        .onAppear {
            vm.displayMode = .drawn
        }
    }
}

struct KvgView_Previews: PreviewProvider {
    static var previews: some View {
        KvgPreviewView()
    }
}
