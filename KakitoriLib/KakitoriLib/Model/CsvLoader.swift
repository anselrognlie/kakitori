//
//  CsvLoader.swift
//  KakitoriLib
//
//  Created by Ansel Rognlie on 9/3/22.
//

import Foundation

public class CsvLoader {
    public class CsvLineParser {
        let line: String
        var pos: String.Index
        let delim = ","
        let quote = "\""
        var inQuote = false

        init(_ line: String) {
            self.line = line
            pos = self.line.startIndex
        }

        func nextField() -> String? {
            let startPos = pos
            if startPos == line.endIndex {
                return nil
            }

            var field = [String]()
            while pos < line.endIndex {
                let nextPos = line.index(pos, offsetBy: 1)
                let nextChar = line[pos..<nextPos]
                if nextChar == delim {
                    if inQuote {
                        field.append(String(nextChar))
                    } else {
                        pos = nextPos
                        break
                    }
                } else if nextChar == quote {
                    inQuote = !inQuote
                } else {
                    field.append(String(nextChar))
                }
                pos = nextPos
            }

            return field.joined()
        }
    }

    static public func load(url: URL) throws -> [[String]] {
        let csvContents = try String(contentsOf: url)
        let lines = csvContents.split(separator: "\n")

        var result: [[String]] = []
        for line in lines {
            var fields = [String]()
            let parser = CsvLineParser(String(line))
            while let field = parser.nextField() {
                fields.append(field)
            }
            result.append(fields)
        }

        return result
    }
}
