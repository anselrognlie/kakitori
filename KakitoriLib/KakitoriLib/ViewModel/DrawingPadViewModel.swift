//
//  DrawingPadViewModel.swift
//  
//
//  Created by Ansel Rognlie on 8/30/22.
//

import Foundation
import CoreGraphics
import SwiftUI

public class DrawingPadViewModel: ObservableObject {
    @Published public var currentDrawing: Drawing = Drawing()
    @Published public var drawings: [Drawing] = [Drawing]()
    @Published public var color: Color = Color.black
    @Published public var lineWidth: CGFloat = 3.0

    public init() {}

    public func clear() {
        drawings = [Drawing]()
        currentDrawing = Drawing()
    }

    public func undo() {
        if !drawings.isEmpty {
            drawings.removeLast()
        }
    }
}
