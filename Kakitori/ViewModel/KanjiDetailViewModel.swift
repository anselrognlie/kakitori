//
//  KanjiDetailViewModel.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/4/22.
//

import Foundation
import KakitoriLib

class KanjiDetailViewModel: ObservableObject {
    @Published public var data: JoyoKanji
    @Published public var kvgVm: KvgViewModel?

    public init(data: JoyoKanji) {
        self.data = data

        let fileBase = data.glyph?.kvgCharacterCode()
        if let fileBase = fileBase {
            kvgVm = KvgViewModel(from: makeGlyphUrl(fileBase: fileBase),
                displayMode: .drawn)
        }
    }

    func makeGlyphUrl(fileBase: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent("kanjivg")
            .appendingPathComponent("kanji")
            .appendingPathComponent("\(fileBase).svg")
    }

    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}
