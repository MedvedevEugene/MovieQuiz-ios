import Foundation

struct NetworkClient {

    private enum NetworkError: Error {
        case invalidResponse
    }
    
    func fetch(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let session = URLSession.shared
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let receivedData = data else { return }
            completion(.success(receivedData))
        }
        
        task.resume()
    }
}
