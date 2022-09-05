//
//  GlyphMoveStrokePart.swift
//  
//
//  Created by Ansel Rognlie on 8/22/22.
//

import Foundation
import CoreGraphics

public class MoveStrokePart: StrokePart {

    let isRelative: Bool
    let x: Double
    let y: Double

    public init(id: Int, isRelative: Bool, x: Double, y: Double) {
        self.isRelative = isRelative
        self.x = x
        self.y = y
        super.init(id: id)
    }

    public override func toPath(pathBuilder: PathBuilder) {
        var dx: CGFloat = 0
        var dy: CGFloat = 0

        if (isRelative) {
            dx = pathBuilder.currentPoint.x;
            dy = pathBuilder.currentPoint.y;
        }

        let newPoint = CGPoint(x: x + dx, y: y + dy)
        pathBuilder.move(to: newPoint)
    }
}
