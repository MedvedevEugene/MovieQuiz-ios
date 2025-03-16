import UIKit

protocol MovieQuizView: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func displayResultAlert(title: String, message: String)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func highlightImageBorder(isCorrect: Bool)
    func resetImageBorder()
}

final class MovieQuizViewController: UIViewController, MovieQuizView {
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLable: UILabel!
    @IBOutlet private var counterLable: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // Презентер
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeDependencies()
        
        counterLable.accessibilityIdentifier = "Index"
    }
    
    private func setupUI() {
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
    }
    
    private func initializeDependencies() {
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil)
        let statisticService = StatisticService()
        
        presenter = MovieQuizPresenter(
            view: self,
            questionFactory: questionFactory,
            statisticService: statisticService
        )
        questionFactory.delegate = presenter
        presenter.startQuiz()
    }
    
    // MARK: - MovieQuizView Methods
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLable.text = step.question
        counterLable.text = step.questionNumber
    }
    
    func displayResultAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default) { [weak self] _ in
            self?.presenter.restartQuiz()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Невозможно загрузить данные",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            self?.presenter.restartApp()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.didTapAnswer(isYes: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.didTapAnswer(isYes: false)
    }
}
