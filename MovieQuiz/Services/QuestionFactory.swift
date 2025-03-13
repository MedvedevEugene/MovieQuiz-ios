import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - Load Data
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.handleLoadResult(result)
            }
        }
    }
    
    private func handleLoadResult(_ result: Result<MostPopularMovies, Error>) {
        switch result {
        case .success(let mostPopularMovies):
            self.movies = mostPopularMovies.items
            self.delegate?.didLoadDataFromServer()
        case .failure(let error):
            self.delegate?.didFailToLoadData(with: error)
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.processNextQuestion()
        }
    }
    
    private func processNextQuestion() {
        guard let movie = movies.randomElement() else { return }
        
        let imageURL = movie.resizedImageURL
        
        guard let imageData = try? Data(contentsOf: imageURL) else {
            print("Ошибка загрузки изображения с URL:", imageURL)
            return
        }
        
        let ratingValue = Float(movie.rating) ?? 0
        let questionText = "Рейтинг этого фильма больше чем 7?"
        let isAnswerCorrect = ratingValue > 7
        
        let question = QuizQuestion(image: imageData, text: questionText, correctAnswer: isAnswerCorrect)
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didReceiveNextQuestion(question: question)
        }
    }
}
