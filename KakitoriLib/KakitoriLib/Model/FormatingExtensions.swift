//
//  FormatingExtensions.swift
//  KakitoriLib
//
//  Created by Ansel Rognlie on 9/4/22.
//

import Foundation

extension StringProtocol {
    public func leftPad(length: Int, padChar: String) -> String {
        let padLen = length - self.count

        if padLen < 1 { return String(self) }

        var pad = [String]()
        for _ in 0..<(padLen / padChar.count) {
            pad.append(padChar)
        }

        return "\(pad.joined())\(self)"
    }
}

public extension Float {
    func toKanken() -> String {
        let low = floor(self)
        let high = ceil(self)
        if self > low && self < high {
            return String(format: "%.1f", self)
        } else {
            return String(format: "%.0f", self)
        }
    }
}

public extension Int {
    func toJoyo() -> String {
        if self > 7 {
            return "-"
        } else if self == 7 {
            return "常"
        } else {
            return String(self)
        }
    }
}

