//
//  KvgViewModel.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/21/22.
//

import SwiftUI

public enum KvgDisplayMode: Int, CaseIterable {
    case plain = 0, drawn, animatedPending, animated, drawnWithLabels, animatedWithLabelsPending, animatedWithLabels
}

public class KvgViewModel: ObservableObject {
    @Published var strokeData: GlyphData?
    @Published public var displayMode: KvgDisplayMode = .plain

    public init() {
        //        let writer = PrintStatusWriter()
        let bundle = Bundle.main
//        let urlToSvg = bundle.url(forResource: "KVG-09b31", withExtension: "svg")
//        let urlToSvg = bundle.url(forResource: "08ff7", withExtension: "svg")
        let urlToSvg = bundle.url(forResource: "09d07", withExtension: "svg")
        //        let urlToSvg = bundle.url(forResource: "KVG-4eee", withExtension: "svg")

        loadStrokeData(from: urlToSvg)
        displayMode = .drawn
    }

    public init(from: URL, displayMode: KvgDisplayMode = .drawnWithLabels) {
        self.displayMode = displayMode
        loadStrokeData(from: from)
    }

    public func loadStrokeData(from: URL?) {
        strokeData = nil
        if let url = from {
//            print("\(from?.absoluteString ?? "missing url")")

            let parserDelegate = StrokeDataParserDelegate()
//            parserDelegate.writer = PrintStatusWriter()
            let loader = StrokeDataLoader(parserDelegate: parserDelegate)
            var error: Error?
            do {
                strokeData = try loader.loadFrom(url: url, error: &error)
            } catch {
                print("error loading stroke data for: \(from?.absoluteString ?? "unknown")")
            }
        }
    }

    public func animate() {
        if displayMode == .drawn || displayMode == .animated {
            displayMode = .animatedPending
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.displayMode = .animated
            }
        } else if  displayMode == .drawnWithLabels || displayMode == .animatedWithLabels {
            displayMode = .animatedWithLabelsPending
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.displayMode = .animatedWithLabels
            }
        }
    }

    public func nextDisplayMode() {
        //        var nextValue = displayMode.rawValue + 1
        //        nextValue = nextValue % KvgDisplayMode.allCases.count
        //        displayMode = KvgDisplayMode(rawValue: nextValue)!
        switch displayMode {
        case .plain:
            displayMode = .drawn
        case .drawn:
            displayMode = .animated
        case .animated:
            displayMode = .drawnWithLabels
        case .drawnWithLabels:
            displayMode = .animatedWithLabels
        case .animatedWithLabels:
            displayMode = .plain
        case .animatedPending:
            displayMode = .animated
        case .animatedWithLabelsPending:
            displayMode = .animatedWithLabels
        }
    }

    public var hasStrokeData: Bool {
        return strokeData != nil
    }

    public var showDrawn: Bool {
        return displayMode == .drawn || displayMode == .drawnWithLabels ||
        displayMode == .animated || displayMode == .animatedWithLabels ||
        displayMode == .animatedPending || displayMode == .animatedWithLabelsPending
    }

    public var showLabels: Bool {
        return displayMode == .drawnWithLabels ||
        displayMode == .animatedWithLabels
    }

    public var showGlyph: Bool {
        return displayMode == .plain
    }

    public var isAnimated: Bool {
        return displayMode == .animated || displayMode == .animatedWithLabels ||
        displayMode == .animatedPending || displayMode == .animatedWithLabelsPending
    }

    public var isPending: Bool {
        return displayMode == .animatedPending || displayMode == .animatedWithLabelsPending
    }
}
