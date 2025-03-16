//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Евгений Медведев on 13.03.2025.
//
import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showQuizResults(result: QuizResultsViewModel)
    func processAnswer(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}


