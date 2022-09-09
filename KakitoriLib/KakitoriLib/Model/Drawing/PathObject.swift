//
//  PathObject.swift
//  KakitoriLib
//
//  Created by Ansel Rognlie on 9/8/22.
//

import Foundation
import SwiftUI

public class PathObject: NSObject, Codable {
    var path: Path!

    public init(path: Path) {
        self.path = path
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.description, forKey: .path)
    }

    public required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let pathDesc = try values.decode(String.self, forKey: .path)
        self.init(path: Path(pathDesc)!)
    }

    enum CodingKeys: String, CodingKey {
        case path
    }
}
