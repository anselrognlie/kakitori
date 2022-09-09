//
//  InitializeQuizView.swift
//  Kakitori
//
//  Created by Ansel Rognlie on 9/7/22.
//

import SwiftUI

struct InitializeQuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var msg: String = ""

    func makeDefaultUser() throws -> User {
        let req = User.fetchRequest()
        if let users = try? viewContext.fetch(req) {
            if users.count > 0 {
                msg = "has user"
                return users[0]
            }
        }

        // no user, so make one
        let user = User(context: viewContext)
        user.id = UUID()
        user.name = "Default User"
        try viewContext.save()

        msg = "new user"
        return user
    }

    func makeFirstQuiz(for user: User) throws -> Quiz {
        let req = Quiz.fetchRequest()
        req.predicate = NSPredicate(format: "user == %@", argumentArray: [user])
        if let quizzes = try? viewContext.fetch(req) {
            if quizzes.count > 0 {
                msg = "has quiz"
                return quizzes[0]
            }
        }

        // no quiz
        let quiz = Quiz(context: viewContext)
        quiz.user = user
        quiz.created = .now
        quiz.lastVisited = .now
        try viewContext.save()

        try populateQuiz(quiz)

        msg = "new quiz"
        return quiz
    }

    func populateQuiz(_ quiz: Quiz) throws {
        let req = JoyoKanji.fetchRequest()
        req.predicate = NSPredicate(format: "grade == %@", argumentArray: [1 as NSNumber])
        let kanjis = try viewContext.fetch(req)
        for kanji in kanjis {
            let question = QuizQuestion(context: viewContext)
            question.kanji = kanji
            question.quiz = quiz
        }

        try viewContext.save()
    }

    func doInit() throws {
        let user = try makeDefaultUser()
        _ = try makeFirstQuiz(for: user)
    }

    var body: some View {
        Text(msg)
        .onAppear {
            do {
                try doInit()
            } catch {
                msg = "Error making quiz: \(error)"
            }
        }
    }
}

struct InitializeQuizView_Previews: PreviewProvider {
    static var previews: some View {
        InitializeQuizView()
    }
}
