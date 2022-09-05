//
//  KvgStringExtensions.swift
//  KakitoriLib
//
//  Created by Ansel Rognlie on 9/4/22.
//

import Foundation

extension StringProtocol {
    public func kvgCharacterCode() -> String {
        let charCount = self.unicodeScalars.count
        if charCount > 1 {
            return ""
        }

        guard let code = self.unicodeScalars.first else { return "" }
        let codeStr = String(code.value, radix: 16)
        return codeStr.leftPad(length: 5, padChar: "0")
    }
}
