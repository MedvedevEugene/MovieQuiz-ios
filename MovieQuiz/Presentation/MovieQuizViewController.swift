import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initializeDependencies()
    }
    
    private func setupUI() {
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
    }
    
    private func initializeDependencies() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: self?.convert(model: question) ?? QuizStepViewModel(image: UIImage(), question: "", questionNumber: ""))
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLable.text = step.question
        counterLable.text = step.questionNumber
    }
    
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol!
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func processAnswer(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.resetUIAfterAnswer()
        }
    }
    
    private func resetUIAfterAnswer() {
        showNextQuestionOrResults()
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Result Alert
    private func showQuizResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bestGameDate = statisticService.bestGame.date.dateTimeString
        let messageText = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGameDate))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        displayResultAlert(title: "Этот раунд окончен!", message: messageText)
    }
    
    private func displayResultAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default) { [weak self] _ in
            self?.restartQuiz()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showQuizResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Network Error Handling
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Невозможно загрузить данные", preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { _ in
            self.restartApp()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func restartApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - UI Elements
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLable: UILabel!
    @IBOutlet private var counterLable: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        processAnswer(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        processAnswer(isCorrect: !currentQuestion.correctAnswer)
    }
}
