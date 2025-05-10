import XCTest

@testable import MovieQuiz

// MARK: - Мок для представления (View)
final class MovieQuizViewMock: MovieQuizView {
    func show(quiz step: QuizStepViewModel){}
    func displayResultAlert(title: String, message: String){}
    func showLoadingIndicator(){}
    func hideLoadingIndicator(){}
    func showNetworkError(message: String){}
    func highlightImageBorder(isCorrect: Bool){}
    func resetImageBorder(){}
}

// MARK: - Мок для фабрики вопросов
final class QuestionFactoryMock: QuestionFactoryProtocol {
    func loadData() { }
    func requestNextQuestion() { }
}

// MARK: - Мок для сервиса статистики
final class StatisticServiceMock: StatisticServiceProtocol {
    var gamesCount: Int = 0
    var bestGame: GameResult = GameResult(correct: 0, total: 0, date: Date())
    var totalAccuracy: Double { return 0.0 }
    var overallStatistic: String { return "" }
    
    func store(correct count: Int, total amount: Int) { }
}

// MARK: - Тесты для MovieQuizPresenter
final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewMock = MovieQuizViewMock()
        let questionFactoryMock = QuestionFactoryMock()
        let statisticServiceMock = StatisticServiceMock()
        
        let sut = MovieQuizPresenter(
            view: viewMock,
            questionFactory: questionFactoryMock,
            statisticService: statisticServiceMock
        )
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
