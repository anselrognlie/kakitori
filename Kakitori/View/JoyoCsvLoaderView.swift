//
//  JoyoCsvLoaderView.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/1/22.
//

import SwiftUI
import KakitoriLib

struct JoyoCsvLoaderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var msg: String?

    func loadCsv() throws {
        let bundle = Bundle.main
        guard let urlToCsv = bundle.url(forResource: "joyo", withExtension: "csv") else { return }

        let csvData = try CsvLoader.load(url: urlToCsv)
        msg = "File has \(csvData.count) lines"
        for row in csvData {
            let newKanji = JoyoKanji(context: viewContext)
            newKanji.glyph = row[0]
            newKanji.grade = Int16(row[1]) ?? 7
            newKanji.kanken = Float(row[2]) ?? 0
            newKanji.gloss = row[3]
            newKanji.readings = row[4]
        }

        try viewContext.save()
    }

    var body: some View {
        Text(msg ?? /*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        .task {
            do {
                try loadCsv()
            } catch {
                msg = "Error loading url: \(error)"
            }
        }
    }
}

struct JoyoCsvLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        JoyoCsvLoaderView()
    }
}
