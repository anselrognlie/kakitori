//
//  PathExtensions.swift
//  KakitoriLib
//
//  Created by Ansel Rognlie on 9/7/22.
//

import Foundation
import SwiftUI

extension Path: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.description, forKey: .path)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let pathDesc = try values.decode(String.self, forKey: .path)
        self.init(pathDesc)!
    }

    enum CodingKeys: String, CodingKey {
        case path
    }

}
