//
//  StatusWriter.swift
//  
//
//  Created by Ansel Rognlie on 8/21/22.
//

import Foundation

public protocol StatusWriter {
    func write(_ msg: String)
    func writeLine(_ msg: String)
}
