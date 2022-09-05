//
//  DrawingPadWrapperView.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/30/22.
//

import SwiftUI
import KakitoriLib

struct DrawingPadWrapperView: View {
    @StateObject var vm = DrawingPadViewModel()

    var body: some View {
        VStack {
            DrawingPadView(vm: vm)
            .frame(width: 300, height: 300)
            .clipShape(Rectangle())
            HStack {
            Button("Clear") {
                vm.clear()
            }
            Button("Undo") {
                vm.undo()
            }
            }
        }
    }
}

struct DrawingPadWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPadWrapperView()
    }
}
