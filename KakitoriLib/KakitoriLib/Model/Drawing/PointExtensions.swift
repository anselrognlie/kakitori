//
//  PointExtensions.swift
//  KakitoriLib
//
//  Created by Ansel Rognlie on 9/7/22.
//

import Foundation
import CoreGraphics

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

