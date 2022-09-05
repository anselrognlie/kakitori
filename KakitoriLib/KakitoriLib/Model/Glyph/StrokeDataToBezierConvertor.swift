//
//  StrokeDataToBezierConvertor.swift
//  
//
//  Created by Ansel Rognlie on 8/22/22.
//

import Foundation
import UIKit

class StrokeDataToBezierConvertor {
    func convertStrokes(_ strokes: [GlyphStroke]) -> [UIBezierPath] {
        let builder = BezierPathBuilder()

        for stroke in strokes {
            for part in stroke.strokeParts {
                part.toPath(pathBuilder: builder)
            }
        }

        return builder.paths
    }
}
