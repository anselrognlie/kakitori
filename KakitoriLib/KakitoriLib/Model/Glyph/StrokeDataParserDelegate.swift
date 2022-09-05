//
//  StrokeDataParserDelegate.swift
//  
//
//  Created by Ansel Rognlie on 8/21/22.
//

import Foundation

public enum KvgTag: String {
    case svg = "svg", path = "path", group = "g", text = "text"
}

public enum KvgAttribute: String {
    case viewBox = "viewBox", pathData = "d", id = "id", style = "style",
         element = "kvg:element", transform = "transform"
}

public enum KvgOperator: String {
    case matrix = "matrix("
}

public enum KvgStrokeAttribute: String {
    case width = "stroke-width", lineCap = "stroke-linecap",
         lineJoin = "stroke-linejoin"
}

public enum KvgFontAttribute: String {
    case size = "font-size"
}

public enum KvgLineJoinStyle: String {
    case round = "round"
}

public enum KvgLineCapStyle: String {
    case round = "round"
}

public enum KvgAttributePrefix: String {
    case pathsId = "kvg:StrokePaths_", numbersId = "kvg:StrokeNumbers_"
}

public enum KvgParsingError: Error {
    case invalidViewport
    case unknownCommand(command: String)
    case invalidMove
    case invalidCurve
    case noData
}

func parseAttributes(_ attr: String) -> [String:String] {
  let pairArray = attr.split(separator: ";")
  var result = [String:String]()

  for pairStr in pairArray {
    if (pairStr.count == 0) { continue }

    let pair = pairStr.split(separator: ":")
    let key = String(pair[0])
    let value = String(pair[1])
    result[key] = value
  }

  return result
}

public class StrokeDataParserDelegate: NSObject, XMLParserDelegate {

    static private let ViewportDelimeter: Character = " "

    public var writer: StatusWriter?
    public private(set) var lastError: Error?
    public private(set) var strokeData: GlyphData!
    public private(set) var parsed: Bool = false

    private var textChars: String?
    private var glyph: String?
    private var a: Double, b: Double, c: Double,
                d: Double, e: Double, f: Double

    override public init() {
        a = 0
        b = 0
        c = 0
        d = 0
        e = 0
        f = 0
        super.init()
        reset()
    }

    public func reset() {
        textChars = nil
        lastError = nil
        glyph = nil
        parsed = false
        strokeData = GlyphData()
        a = 0
        b = 0
        c = 0
        d = 0
        e = 0
        f = 0
    }

    public func parserDidStartDocument(_ parser: XMLParser) {
        parsed = true
    }

    public func parser(_ parser:XMLParser,
                       didStartElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qname: String?,
                       attributes attributeDict: [String: String]) {
        var success = true

        writer?.writeLine(elementName)
        success = parseStartStateWithElement(elementName, attributes:attributeDict);

        if (!success) {
            parser.abortParsing()
        }
    }

    public func parser(_ parser:XMLParser,
                       didEndElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qname: String?) {
        var success = true

        success = parseEndStateWithElement(elementName)

        if (!success) {
            parser.abortParsing()
        }
        writer?.writeLine("/\(elementName)")
    }

    public func parser(_ parser: XMLParser,
                       foundCharacters: String) {
        writer?.writeLine(foundCharacters)
        textChars?.append(foundCharacters)
    }

    func parseEndStateWithElement(_ elementName: String) -> Bool {

        if let text = textChars, (KvgTag.text == KvgTag(rawValue: elementName)) {

            let number = StrokeNumber(id: strokeData.numbers.count,
                text: text,
                a: a, b: b, c: c, d: d, e: e, f: f)

            textChars = nil;

            strokeData.addStrokeNumber(number)
        }

        return true
    }


    func parseStartStateWithElement(_ elementName:String,
                                    attributes attributeDict: [String: String]) -> Bool {

        switch KvgTag(rawValue: elementName) {
        case .svg:
            return parseViewportString(attributeDict[KvgAttribute.viewBox.rawValue])
        case .path:
            return parsePath(
                id: attributeDict[KvgAttribute.id.rawValue],
                dataAttr: attributeDict[KvgAttribute.pathData.rawValue])
        case .group:
            return parseGroup(attributeDict)
        case .text:
            return parseText(attributeDict)
        default:
            return true
        }
    }

    func parseViewportString(_ viewportString: String?) -> Bool {

        if let viewportString = viewportString {
            let parts = viewportString.split(separator: StrokeDataParserDelegate.ViewportDelimeter)

            if (parts.count != 4) {
                lastError = KvgParsingError.invalidViewport
                return false
            }

            strokeData.setViewport(left: Double(parts[0])!,
                                   top: Double(parts[1])!,
                                   right: Double(parts[2])!,
                                   bottom: Double(parts[3])!)

            writer?.writeLine("[viewBox \(strokeData.viewLeft), \(strokeData.viewTop), \(strokeData.viewRight), \(strokeData.viewBottom)]")
            
            return true
        }

        lastError = KvgParsingError.invalidViewport
        return false
    }

    func parsePath(id: String?, dataAttr: String?) -> Bool {
        guard let id = id, let dataAttr = dataAttr else { return false }

        let tokens = StrokePartTokenizer(dataAttr)
        var parts = [StrokePart]()
        var success = true

        while let cmd = tokens.nextCommand() {
            var isRelative = false
            var part: StrokePart?
            success = true

            switch cmd {
            case "m":
                isRelative = true
                fallthrough

            case "M":
                part = parseMoveToUsingTokenizer(tokens, offset: parts.count, relative: isRelative)
                break

            case "c":
                isRelative = true
                fallthrough

            case "C":
                part = parseCurveUsingTokenizer(tokens, offset: parts.count, relative: isRelative)
                break

            case "s":
                isRelative = true
                fallthrough

            case "S":
                part = parseSmoothCurveUsingTokenizer(tokens, offset: parts.count, relative: isRelative)
                break

            default:
                lastError = KvgParsingError.unknownCommand(command: String(cmd))
                return false
            }

            if let part = part {
                parts.append(part)
                success = true
            }
        }

        if (success && parts.count > 0) {
            setStrokeWithParts(id: id, parts: parts)
        }

        return success;
    }

    func parseMoveToUsingTokenizer(_ tokenizer: StrokePartTokenizer, offset: Int,  relative isRelative:Bool) -> StrokePart? {

        let x = tokenizer.nextNumber()
        let y = tokenizer.nextNumber()

        if (x.isNaN || y.isNaN) {
            lastError = KvgParsingError.invalidMove
            return nil
        }

        writer?.writeLine("[\(isRelative ? "m" : "M") \(x), \(y)]")

        return MoveStrokePart(id: offset, isRelative: isRelative, x: x, y: y)
    }

    func parseCurveUsingTokenizer(_ tokenizer: StrokePartTokenizer, offset: Int, relative isRelative: Bool) -> StrokePart? {

        let xcp1 = tokenizer.nextNumber()
        let ycp1 = tokenizer.nextNumber()
        let xcp2 = tokenizer.nextNumber()
        let ycp2 = tokenizer.nextNumber()
        let x2 = tokenizer.nextNumber()
        let y2 = tokenizer.nextNumber()

        if (xcp1.isNaN || ycp1.isNaN || xcp2.isNaN || ycp2.isNaN || x2.isNaN || y2.isNaN) {
            lastError = KvgParsingError.invalidCurve
            return nil
        }

        writer?.writeLine("[\(isRelative ? "c" : "C") (\(xcp1), \(ycp1)) (\(xcp2), \(ycp2)) (\(x2), \(y2))]")

        return CurveStrokePart(id: offset, isRelative: isRelative,
            xcp1: xcp1, ycp1: ycp1,
            xcp2: xcp2, ycp2: ycp2,
            x2: x2, y2: y2)
    }

    func parseSmoothCurveUsingTokenizer(_ tokenizer: StrokePartTokenizer, offset: Int, relative isRelative: Bool) -> StrokePart? {

        let xcp2 = tokenizer.nextNumber()
        let ycp2 = tokenizer.nextNumber()
        let x2 = tokenizer.nextNumber()
        let y2 = tokenizer.nextNumber()

        if (xcp2.isNaN || ycp2.isNaN || x2.isNaN || y2.isNaN) {
            lastError = KvgParsingError.invalidCurve
            return nil
        }

        writer?.writeLine("[\(isRelative ? "s" : "S") (\(xcp2), \(ycp2)) (\(x2), \(y2))]")

        return SmoothCurveStrokePart(id: offset, isRelative: isRelative,
            xcp2: xcp2, ycp2: ycp2,
            x2: x2, y2: y2)
    }

    func setStrokeWithParts(id: String, parts:[StrokePart]) {
        let stroke = GlyphStroke(id: id, strokeParts: parts)
        strokeData.addStroke(stroke)
    }

    func parseGroup(_ attributeDict: [String:String]) -> Bool {
        let idStr = attributeDict[KvgAttribute.id.rawValue]
        guard let idStr = idStr else { return true }

        if (idStr.starts(with: KvgAttributePrefix.pathsId.rawValue)) {
            return parsePathsGroupAttributes(attributeDict)
        } else if (idStr.starts(with: KvgAttributePrefix.numbersId.rawValue)) {
            return parseNumbersGroupAttributes(attributeDict)
        } else if let el = attributeDict[KvgAttribute.element.rawValue] {
            if (glyph == nil) {
                glyph = el
                strokeData.setGlyph(el)
            }
        }

        return true
    }

    func parsePathsGroupAttributes(_ attributes: [String:String]) -> Bool {
        let style = attributes[KvgAttribute.style.rawValue];
        guard let style = style else { return false }

        let styleAttr = parseAttributes(style)
        return parsePathsStyleAttributes(styleAttr)
    }

    func parseNumbersGroupAttributes(_ attributes: [String:String]) -> Bool {
        let style = attributes[KvgAttribute.style.rawValue];
        guard let style = style else { return false }

        let styleAttr = parseAttributes(style);
        return parseNumbersStyleAttributes(styleAttr)
    }

    func parsePathsStyleAttributes(_ styleAttr: [String:String]) -> Bool {
        let strokeWidthStr = styleAttr[KvgStrokeAttribute.width.rawValue]
        if let strokeWidthStr = strokeWidthStr {
            let scanner = Scanner(string: strokeWidthStr)
            let result = scanner.scanDouble()
            guard let result = result else { return false }

            strokeData.setStrokeWidth(result)
        }

        let strokeCapStyle = styleAttr[KvgStrokeAttribute.lineCap.rawValue]
        if let strokeCapStyle = strokeCapStyle {
            if (strokeCapStyle == KvgLineCapStyle.round.rawValue) {
                strokeData.setStrokeCapStyle(StrokeCapStyle.round)
            } else {
                return false
            }
        }

        let strokeJoinStyle = styleAttr[KvgStrokeAttribute.lineJoin.rawValue]
        if let strokeJoinStyle = strokeJoinStyle {
            if (strokeJoinStyle == KvgLineJoinStyle.round.rawValue) {
                strokeData.setStrokeJoinStyle(StrokeJoinStyle.round)
            } else {
                return false
            }
        }

        return true
    }

    func parseNumbersStyleAttributes(_ styleAttr: [String:String]) -> Bool {

        guard let fontSizeStr = styleAttr[KvgFontAttribute.size.rawValue] else {
            return false
        }

        let scanner = Scanner(string: fontSizeStr)
        guard let result = scanner.scanDouble() else { return false }

        strokeData.setFontSize(result)

        return true
    }

    func parseText(_ attributeDict: [String:String]) -> Bool {
        if let transform = attributeDict[KvgAttribute.transform.rawValue] {
            if (transform.starts(with: KvgOperator.matrix.rawValue)) {
                let dataIndex = transform.index(transform.startIndex,
                    offsetBy: KvgOperator.matrix.rawValue.count)
                let numbers = transform[dataIndex...]
                let scanner = Scanner(string: String(numbers))

                guard let a = scanner.scanDouble() else { return false }
                guard let b = scanner.scanDouble() else { return false }
                guard let c = scanner.scanDouble() else { return false }
                guard let d = scanner.scanDouble() else { return false }
                guard let e = scanner.scanDouble() else { return false }
                guard let f = scanner.scanDouble() else { return false }

                self.a = a
                self.b = b
                self.c = c
                self.d = d
                self.e = e
                self.f = f

                textChars = String()
            } else {
                return false
            }
        } else {
            return false
        }

        return true
    }
}

