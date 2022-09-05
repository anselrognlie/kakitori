//
//  KanjiDetailView.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/4/22.
//

import SwiftUI
import KakitoriLib

extension View {
    func rowHeading(width columnWidth: CGFloat) -> some View {
        return self
            .foregroundColor(Color.gray)
            .frame(width: columnWidth, alignment: .leading)
    }
}

extension View {
    func addActions(text: String?) -> some View {
        return Group {
            if let text = text {
                self.contextMenu(ContextMenu(menuItems: {
                    Button("Copy", action: {
                        UIPasteboard.general.string = text
                    })
                }))
            } else {
                self
            }
        }
    }
}

struct KanjiDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var vm: KanjiDetailViewModel
    @State private var height: CGFloat = 0
    let verticalPadding: CGFloat = 5
    let columnWidth: CGFloat = 110

    private struct KanjiDetail: Identifiable {
        let id = UUID()
        let label: String
        let data: String?
    }

    var fileBase: String?
    var glyph: String {
        return vm.data.glyph ?? "?"
    }

    init(vm: KanjiDetailViewModel) {
        self.vm = vm
    }

    var hasKvg: Bool {
        return vm.kvgVm?.hasStrokeData ?? false
    }

    var body: some View {

        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {

                HStack(alignment: .bottom) {
                    Text(glyph)
                        .font(.custom(GlyphConfig.fontName, size: 128))
                        .padding(.horizontal)
                    Spacer()
                    if hasKvg, let kvgVm = vm.kvgVm {
                        KvgView(viewModel: kvgVm)
                            .border(.black, width: 1)
                            .frame(height: 96)
                            .padding(.horizontal)
                            .padding(.vertical, 7)
                            .onTapGesture {
                                kvgVm.animate()
                            }
                    }
                }
                .padding(.vertical, 20)

                ScrollView {
                    HStack() {
                        Text("Meaning")
                        .rowHeading(width: columnWidth)
                        Text(vm.data.gloss ?? "")
                        .addActions(text: vm.data.gloss)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, verticalPadding)
                    HStack {
                        Text("Readings")
                        .rowHeading(width: columnWidth)
                        Text(vm.data.readings ?? "")
                        .addActions(text: vm.data.readings)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, verticalPadding)
                    HStack {
                        Text("Joyo Grade")
                        .rowHeading(width: columnWidth)
                        Text(Int(vm.data.grade).toJoyo())
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, verticalPadding)
                    HStack {
                        Text("Kanken Level")
                        .rowHeading(width: columnWidth)
                        Text(vm.data.kanken.toKanken())
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, verticalPadding)
                }
                Spacer()
            }
            .padding([.top], 30)

//            Button {
//                dismiss()
//                if let kvgVm = vm.kvgVm {
//                    kvgVm.displayMode = .drawn
//                }
//            } label: {
//                HStack {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.blue)
//                        .imageScale(.large)
//                    Text("Back")
//                        .font(.title3)
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding([.top, .leading], 5)
        }
        .navigationTitle("Kanji Detail")
//        .navigationBarHidden(true)
    }
}

struct KanjiDetailViewWrapper_Previews: View {
    @StateObject var vm: KanjiDetailViewModel = KanjiDetailViewWrapper_Previews.initVm()

    static func initVm() -> KanjiDetailViewModel {
        let newKanji = JoyoKanji(
            context: PersistenceController.preview.container.viewContext)
        newKanji.glyph = "仮"
        newKanji.grade = 5
        newKanji.kanken = 6
        newKanji.gloss = "temporary"
        newKanji.readings = "カ,(ケ),かり"

        return KanjiDetailViewModel(data: newKanji)
    }

    var body: some View {
        NavigationView {
            KanjiDetailView(vm: vm)
        }
    }
}

struct KanjiDetailView_Previews: PreviewProvider {

    static var previews: some View {
        KanjiDetailViewWrapper_Previews()
    }
}
