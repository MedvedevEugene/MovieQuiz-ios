//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Евгений Медведев on 13.03.2025.
//
import UIKit

final class MovieQuizPresenter: NSObject {
    
    // MARK: - Properties
    private weak var view: MovieQuizView?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    
    // MARK: - Initialization
    init(view: MovieQuizView,
         questionFactory: QuestionFactoryProtocol,
         statisticService: StatisticServiceProtocol) {
        self.view = view
        self.questionFactory = questionFactory
        self.statisticService = statisticService
    }
    
    // MARK: - Public Methods
    func startQuiz() {
        view?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didTapAnswer(isYes: Bool) {
        guard let question = currentQuestion else { return }
        let isCorrect = (isYes == question.correctAnswer)
        if isCorrect {
            correctAnswers += 1
        }
        
        view?.highlightImageBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.view?.resetImageBorder()
            self?.showNextQuestionOrResults()
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func restartApp() {
        // Перезапуск приложения (смена корневого контроллера)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showQuizResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showQuizResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bestGameDate = statisticService.bestGame.date.dateTimeString
        let messageText = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGameDate))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        view?.displayResultAlert(title: "Этот раунд окончен!", message: messageText)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image: image, question: model.text, questionNumber: questionNumber)
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let viewModel = self.convert(model: question)
            self.view?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        view?.showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        view?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
}
