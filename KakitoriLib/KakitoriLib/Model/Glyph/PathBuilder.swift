//
//  PathBuilder.swift
//  
//
//  Created by Ansel Rognlie on 8/28/22.
//

import Foundation
import CoreGraphics

public protocol PathBuilder {
    var currentPoint: CGPoint { get }
    func addCurve(to: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint)
    func addSmoothCurve(to: CGPoint, controlPoint2: CGPoint)
    func move(to: CGPoint)
}
