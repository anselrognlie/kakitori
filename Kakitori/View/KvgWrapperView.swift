//
//  KcgWrapperView.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/28/22.
//

import SwiftUI
import KakitoriLib

fileprivate let kLibrary = [
    ("鬱", "KVG-09b31"),
    ("仮", "KVG-4eee"),
    ("迷", "08ff7"),
]

fileprivate func urlToFile(base: String) -> URL? {
    let bundle = Bundle.main
    return bundle.url(forResource: base, withExtension: "svg")
}

struct KvgWrapperView: View {
    @StateObject var viewModel = KvgViewModel()
    @State var showPicker = false

    var body: some View {
        NavigationView {

            VStack {
                KvgView(viewModel: viewModel)
                    .onTapGesture {
                        viewModel.nextDisplayMode()
                    }

                Button("Pick Character") {
                    showPicker = true
                }

                Spacer()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)

            Text("Kakitori")
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
//        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(isPresented: $showPicker) {

        } content: {
            List(kLibrary, id: \.0) { glyph, name in
                HStack {
                    Spacer()
                    Text(glyph)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showPicker = false
                    viewModel.loadStrokeData(from: urlToFile(base: name))
                }
            }
        }
    }
}

struct KvgWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        KvgWrapperView()
    }
}
