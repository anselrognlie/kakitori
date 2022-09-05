//
//  GlyphStrokePart.swift
//  
//
//  Created by Ansel Rognlie on 8/22/22.
//

import Foundation

public class StrokePart: Identifiable {
    public var id: Int = 0
    public func toPath(pathBuilder: PathBuilder) {}

    init(id: Int) {
        self.id = id
    }
}
