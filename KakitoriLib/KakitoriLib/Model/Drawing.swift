//
//  Drawing.swift
//  
//
//  Created by Ansel Rognlie on 8/30/22.
//  Interpolation code based on: https://github.com/jnfisher/ios-curve-interpolation/blob/master/Curve%20Interpolation/UIBezierPath%2BInterpolation.m

import Foundation
import CoreGraphics
import SwiftUI

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static prefix func -(point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }

    static func *(v: CGPoint, s: CGFloat) -> CGPoint {
        return CGPoint(x: v.x * s, y: v.y * s);
    }

    func midpoint(_ other: CGPoint) -> CGPoint {
        return (self + other) * 0.5
    }

    func dot(_ other: CGPoint) -> CGFloat {
        return self.x * other.x + self.y * other.y
    }

    func lengthSq() -> CGFloat {
        return self.dot(self)
    }

    func length() -> CGFloat {
        return sqrt(lengthSq())
    }
}

public struct Drawing {
    var points: [CGPoint] = [CGPoint]()

    private struct DrawingAdapter {
        var points: [CGPoint]

        var count: Int {
            return points.count + 2
        }

        subscript(index: Int) -> CGPoint {
            if index == 0 {
                let vec = points[1] - points[0]
                return points[0] - vec
            }

            if index == count - 1 {
                let rawCount = points.count
                let vec = points[rawCount - 1] - points[rawCount - 2]
                return points[rawCount - 1] + vec
            }

            return points[index - 1]
        }
    }

    func interpolateCGPointsWithCatmullRom(alpha: Double) -> Path {
        let kEPSILON = 1.0e-5

        if points.count < 1 { return Path() }
        if points.count == 1 {
            var p = Path()
            p.move(to: points[0])
            return p
        }

        let splinePoints = DrawingAdapter(points: points)

        let endIndex = splinePoints.count - 2
        assert(alpha >= 0.0 && alpha <= 1.0, "alpha value is between 0.0 and 1.0, inclusive")

        var path = Path()
        let startIndex = 1
        for ii in startIndex..<endIndex {
            let previi = ii - 1
            let nextii = ii + 1
            let nextnextii = nextii + 1

            let p1 = splinePoints[ii]
            let p0 = splinePoints[previi]
            let p2 = splinePoints[nextii]
            let p3 = splinePoints[nextnextii]

            let d1 = (p1 - p0).length()
            let d2 = (p2 - p1).length()
            let d3 = (p3 - p2).length()

            var b1: CGPoint
            var b2: CGPoint
            if (abs(d1) < kEPSILON) {
                b1 = p1;
            }
            else {
                b1 = p2 * pow(d1, 2*alpha)
                b1 = b1 - (p0 * pow(d2, 2*alpha))
                b1 = b1 + (p1 * (2*pow(d1, 2*alpha) + (3 * pow(d1, alpha) * pow(d2, alpha)) + pow(d2, 2*alpha)))
                b1 = b1 * (1.0 / (3*pow(d1, alpha)*(pow(d1, alpha)+pow(d2, alpha))))
            }

            if (abs(d3) < kEPSILON) {
                b2 = p2
            }
            else {
                b2 = p1 * pow(d3, 2*alpha)
                b2 = b2 - (p3 * pow(d2, 2*alpha))
                b2 = b2 + (p2 * (2*pow(d3, 2*alpha) + 3*pow(d3, alpha)*pow(d2, alpha) + pow(d2, 2*alpha)))
                b2 = b2 * (1.0 / (3*pow(d3, alpha)*(pow(d3, alpha)+pow(d2, alpha))))
            }

            if ii == startIndex {
                path.move(to: p1)
            }

            path.addCurve(to: p2, control1: b1, control2: b2)
        }

        return path
    }
}
