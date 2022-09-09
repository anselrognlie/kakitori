//
//  ShowQuizView.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/8/22.
//

import SwiftUI

struct ShowQuizView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var items: FetchedResults<Quiz>

    var body: some View {
        QuizQuestionsView(quiz: items[0])
    }
}

struct ShowQuizView_Previews: PreviewProvider {
    static var previews: some View {
        ShowQuizView()
    }
}
