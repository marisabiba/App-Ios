import Foundation
import Combine

class UnsplashService {
    private let apiKey = APIConfig.unsplashAPIKey
    private let session = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    
    func searchCityImage(query: String) -> AnyPublisher<String?, Error> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://api.unsplash.com/search/photos?query=\(encodedQuery)%20city&per_page=1")!
        
        var request = URLRequest(url: url)
        request.addValue("Client-ID \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UnsplashResponse.self, decoder: jsonDecoder)
            .map { response -> String? in
                response.results.first?.urls.regular
            }
            .eraseToAnyPublisher()
    }
}

private struct UnsplashResponse: Codable {
    let results: [UnsplashPhoto]
}

private struct UnsplashPhoto: Codable {
    let urls: PhotoURLs
}

private struct PhotoURLs: Codable {
    let regular: String
} 