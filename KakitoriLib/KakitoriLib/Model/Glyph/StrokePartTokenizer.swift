//
//  StrokePartTokenizer.swift
//  
//
//  Created by Ansel Rognlie on 8/23/22.
//

import Foundation

public enum TokenType {
    case command
    case number
    case unknown
}

func s_numberCharacter(_ c: Character) -> Bool {
    if (c >= "0" && c <= "9") {
        return true
    }

    switch (c) {
        case "-", ".":
            return true

        default:
            return false
    }
}

func s_commandCharacter(_ c: Character) -> Bool {
    return (c >= "A" && c <= "Z") || (c >= "a" && c <= "z")
}

func s_dividerCharacter(_ c: Character) -> Bool {
    if (c == " " || c == ",") {
        return true
    }

    return false
}

func s_nextNotDividerIndex(_ str: String, _ position: String.Index) -> String.Index {
    let len = str.endIndex
    var position = position

    while (position < len) {
        let uc = str[position]

        if (!s_dividerCharacter(uc))
        {
            break
        }
        position = str.index(position, offsetBy: 1)
    }

    return position
}


func s_nextNumberCharIndex(_ str: String, _ position: String.Index) -> String.Index? {
    let len = str.endIndex

    let afterDivider = s_nextNotDividerIndex(str, position)

    if (afterDivider < len) {
        let uc = str[afterDivider]

        if (s_numberCharacter(uc))
        {
            return afterDivider
        }
    }

    return nil
}

func s_nextCommandCharIndex(_ str: String, _ position: String.Index) -> String.Index? {
    let len = str.endIndex

    let afterDivider = s_nextNotDividerIndex(str, position)

    if (afterDivider < len) {
        let uc = str[afterDivider]

        if (s_commandCharacter(uc))
        {
            return afterDivider
        }
    }

    return nil
}

func s_nextNotNumberCharIndex(_ str: String, _ position: String.Index) -> String.Index {
    let len = str.endIndex
    var position = position

    while (position < len) {
        let uc = str[position]

        if (!s_numberCharacter(uc)) { break }
        if (uc == "-") { break }

        position = str.index(position, offsetBy: 1)
    }

    return position
}

class StrokePartTokenizer {
    var sourceString: String
    var currentPosition: String.Index

    init(_ string: String) {
        sourceString = string
        currentPosition = string.startIndex
    }

    func nextCommand() -> Character? {
        let len = sourceString.endIndex

        while (currentPosition < len) {
            let uc = sourceString[currentPosition]
            currentPosition = sourceString.index(currentPosition, offsetBy: 1)

            if ((uc >= "A" && uc <= "Z") || (uc >= "a" && uc <= "z"))
            {
                return uc
            }
        }

        return nil
    }

    func peekNext() -> TokenType {
        let nextNumberPos = s_nextNumberCharIndex(sourceString, currentPosition)
        let nextCommandPos = s_nextCommandCharIndex(sourceString, currentPosition)

        if let nextNumberPos = nextNumberPos,
            let nextCommandPos = nextCommandPos {
            if nextNumberPos < nextCommandPos {
                return .number
            } else {
                return .command
            }
        }

        if nextNumberPos != nil {
            return .number
        } else if nextCommandPos != nil {
            return .command
        }

        return .unknown
    }

    func nextNumber() -> Double {
        let start = s_nextNumberCharIndex(sourceString, currentPosition)

        guard let start = start else {
            return Double.nan
        }

        let end = s_nextNotNumberCharIndex(sourceString, sourceString.index(start, offsetBy: 1))
        currentPosition = end;

        if (start >= end) { return Double.nan }

        let numPart = sourceString[start ..< end]
        return Double(numPart) ?? Double.nan
    }

}
