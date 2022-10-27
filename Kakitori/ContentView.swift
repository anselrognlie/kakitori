//
//  ContentView.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/1/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \JoyoKanji.glyph, ascending: true)],
        sortDescriptors: [],
//        predicate: NSPredicate(format: "glyph == %@", "喩"),
//        predicate: NSPredicate(format: "glyph == %@", "迷"),
//        predicate: NSPredicate(format: "grade == %@", 1 as NSNumber),
        animation: .default)
    private var items: FetchedResults<JoyoKanji>

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                List {
                        ForEach(items) { item in
                            NavigationLink {
        //                        VStack {
        //                            Text("\(item.objectID)")
        //                            Text(item.glyph!)
        //                            Text(item.gloss!)
        //                            Text(item.readings!)
        //                            Text("Grade: \(item.grade)")
        //                            Text("Kanken: \(item.kanken.toKanken())")
        //                            Spacer()
        //                        }
        //                        .navigationTitle("Inner View Title")
        //                        .navigationBarTitle("Inner View Bar Title")
                                KanjiDetailView(vm: KanjiDetailViewModel(data: item))
                            } label: {
                                Text(item.glyph!)
                            }
                        }
//                        .onDelete(perform: deleteItems)
                    }
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            EditButton()
//                        }
//                        ToolbarItem {
//                            Button(action: addItem) {
//                                Label("Add Item", systemImage: "plus")
//                            }
//                        }
//                    }
                    .navigationTitle("Kanji")
//                    .navigationBarHidden(true)
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newKanji = JoyoKanji(context: viewContext)
            newKanji.glyph = "仮"
            newKanji.grade = 5
            newKanji.kanken = 6
            newKanji.gloss = "temporary"
            newKanji.readings = "カ,(ケ),かり"

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
