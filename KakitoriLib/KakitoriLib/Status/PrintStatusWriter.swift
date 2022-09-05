//
//  PrintStatusWriter.swift
//  
//
//  Created by Ansel Rognlie on 8/21/22.
//

import Foundation

public class PrintStatusWriter: StatusWriter {
    public init() {}

    public func write(_ msg: String) {
        print(msg, terminator: "")
    }

    public func writeLine(_ msg: String) {
        print(msg)
    }


}
