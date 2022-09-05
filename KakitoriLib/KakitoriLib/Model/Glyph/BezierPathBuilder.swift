//
//  PathBuilder.swift
//  
//
//  Created by Ansel Rognlie on 8/22/22.
//

import Foundation
import CoreGraphics
import UIKit

class BezierPathBuilder: PathBuilder {
    var currentPoint: CGPoint = .zero
    var smoothControlPoint: CGPoint = .zero
    var paths = [UIBezierPath]()
    public private (set) var currentPath: UIBezierPath!

    public func addCurve(to: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        currentPath.addCurve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        smoothControlPoint = to + (to - controlPoint2)
        currentPoint = to
    }

    public func addSmoothCurve(to: CGPoint, controlPoint2: CGPoint) {
        currentPath.addCurve(to: to, controlPoint1: smoothControlPoint, controlPoint2: controlPoint2)
        smoothControlPoint = to + (to - controlPoint2)
        currentPoint = to
    }

    public func move(to: CGPoint) {
        let newPath = UIBezierPath()
        newPath.move(to: to)

        paths.append(newPath)

        currentPoint = to
        currentPath = newPath
    }
}
