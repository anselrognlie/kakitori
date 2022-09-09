//
//  QuizQuestionsView.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/8/22.
//

import SwiftUI

struct QuizQuestionsView: View {
    var quiz: Quiz

//    @FetchRequest(
//        sortDescriptors: [],
//        predicate: NSPredicate(format: "quiz == %@", quiz),
//        animation: .default)
//    private var items: FetchedResults<QuizQuestion>

    @FetchRequest private var items: FetchedResults<QuizQuestion>

    init(quiz: Quiz) {
        self.quiz = quiz
        _items = FetchRequest<QuizQuestion>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "quiz == %@", quiz))
    }

    var body: some View {
        List(items) { question in
            Text(question.kanji?.glyph ?? "無")
        }
    }
}

struct QuizQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
//        QuizQuestionsView()
    }
}
