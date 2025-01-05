import Foundation
import Combine

class PlacesService {
    private let apiKey = APIConfig.googlePlacesAPIKey
    private let session = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    
    func searchPlaces(query: String) -> AnyPublisher<[Place], Error> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedQuery)&types=(cities)&key=\(apiKey)")!
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PlacesResponse.self, decoder: jsonDecoder)
            .map(\.predictions)
            .map { predictions in
                predictions.map { prediction in
                    Place(
                        id: prediction.placeId,
                        name: prediction.structuredFormatting.mainText,
                        fullName: prediction.description,
                        photoReference: nil
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchPlaceImage(photoReference: String) -> AnyPublisher<Data, Error> {
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=\(photoReference)&key=\(apiKey)")!
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

// Response models
private struct PlacesResponse: Codable {
    let predictions: [Prediction]
}

private struct Prediction: Codable {
    let placeId: String
    let description: String
    let structuredFormatting: StructuredFormatting
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case description
        case structuredFormatting = "structured_formatting"
    }
}

private struct StructuredFormatting: Codable {
    let mainText: String
    
    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
    }
} 