//
//  GlyphStroke.swift
//  
//
//  Created by Ansel Rognlie on 8/22/22.
//

import Foundation

public struct GlyphStroke: Identifiable {
    public var id: String
    public var strokeParts: [StrokePart]

    public init(id: String, strokeParts: [StrokePart]) {
        self.id = id
        self.strokeParts = strokeParts
    }
}
