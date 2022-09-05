//
//  StrokeDataLoader.swift
//  
//
//  Created by Ansel Rognlie on 8/21/22.
//

import Foundation

public class StrokeDataLoader {
    private var parserDelegate: StrokeDataParserDelegate

    public init(parserDelegate: StrokeDataParserDelegate) {
        self.parserDelegate = parserDelegate
    }

    public func loadFrom(string: String, error: inout Error?) {
        let data = string.data(using: .utf8)
        if let data = data {
            let parser = XMLParser(data: data)
            parser.delegate = parserDelegate
            parser.parse()
            error = parserDelegate.lastError

            //            return _delegate.strokeData;
        }
    }

    public func loadFrom(url: URL, error: inout Error?) throws -> GlyphData? {
        let parser = XMLParser(contentsOf: url)
        if let parser = parser {
            parser.delegate = parserDelegate
            parser.parse()
            if !parserDelegate.parsed {
                error = KvgParsingError.noData
            } else {
                error = parserDelegate.lastError
            }

            if let error = error {
                throw error
            }

            return parserDelegate.strokeData
        }

        return nil
    }
}
