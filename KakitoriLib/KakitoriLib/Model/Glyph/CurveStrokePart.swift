//
//  GlyphCurveStrokePart.swift
//  
//
//  Created by Ansel Rognlie on 8/22/22.
//

import Foundation
import UIKit

public class CurveStrokePart: StrokePart {

    let isRelative: Bool
    let xcp1: Double
    let ycp1: Double
    let xcp2: Double
    let ycp2: Double
    let x2: Double
    let y2: Double

    public init(id: Int, isRelative: Bool,
            xcp1: Double, ycp1: Double,
            xcp2: Double, ycp2: Double,
            x2: Double, y2: Double) {
        self.isRelative = isRelative
        self.xcp1 = xcp1
        self.ycp1 = ycp1
        self.xcp2 = xcp2
        self.ycp2 = ycp2
        self.x2 = x2
        self.y2 = y2
        super.init(id: id)
    }

    public override func toPath(pathBuilder: PathBuilder) {
        var dx: CGFloat = 0
        var dy: CGFloat = 0

        if (isRelative) {
            dx = pathBuilder.currentPoint.x;
            dy = pathBuilder.currentPoint.y;
        }

        let cp1 = CGPoint(x: xcp1 + dx, y: ycp1 + dy);
        let cp2 = CGPoint(x: xcp2 + dx, y: ycp2 + dy);
        let p2 = CGPoint(x: x2 + dx, y: y2 + dy);

        pathBuilder.addCurve(to: p2, controlPoint1: cp1, controlPoint2: cp2)
   }


}
