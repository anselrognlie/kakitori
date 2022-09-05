//
//  GlyphData.swift
//  
//
//  Created by Ansel Rognlie on 8/21/22.
//

import Foundation
import UIKit

public class GlyphData {
    public private(set) var viewLeft: Double = 0
    public private(set) var viewTop: Double = 0
    public private(set) var viewRight: Double = 0
    public private(set) var viewBottom: Double = 0

    public var viewport: CGRect {
        return CGRect(x: 0, y: 0, width: viewRight - viewLeft, height: viewBottom - viewTop)
    }

    public private(set) var strokeWidth: Double = 0
    public private(set) var fontSize: Double = 0

    public private(set) var strokeCapStyle: StrokeCapStyle = .round
    public private(set) var strokeJoinStyle: StrokeJoinStyle = .round

    public private(set) var glyph: String = ""

    public private(set) var strokes = [GlyphStroke]()

    public private(set) var numbers = [StrokeNumber]()

//    public func convertToPoints() -> [UIBezierPath] {
//        let converter = StrokeDataToBezierConvertor()
//        return converter.convertStrokes(strokes)
//    }
//
    public func addStroke(_ stroke: GlyphStroke) {
      strokes.append(stroke)
    }

    public func setViewport(left: Double, top: Double, right: Double, bottom: Double) {
        viewLeft = left
        viewTop = top
        viewRight = right
        viewBottom = bottom
    }

    func setStrokeWidth(_ width: Double) {
        strokeWidth = width;
    }

    func setStrokeCapStyle(_ style: StrokeCapStyle) {
        strokeCapStyle = style;
    }

    func setStrokeJoinStyle(_ style: StrokeJoinStyle) {
        strokeJoinStyle = style;
    }

    func setGlyph(_ glyph: String) {
        self.glyph = glyph;
    }

    func setFontSize(_ fontSize: Double) {
        self.fontSize = fontSize;
    }

    func addStrokeNumber(_ number: StrokeNumber) {
        numbers.append(number)
    }
}
