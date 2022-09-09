//
//  KakitoriApp.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/1/22.
//

import SwiftUI

@main
struct KakitoriApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//            ItemCountListView(viewModel: viewModel)
//            KvgWrapperView()
//            DrawingPadWrapperView()
//            AnimatedPathView()
//            StrokeWrapperView()
//            KvgLoaderView()
//            JoyoCsvLoaderView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//            InitializeQuizView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            ShowQuizView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
