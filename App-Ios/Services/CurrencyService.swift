import Foundation

class CurrencyService {
    static let shared = CurrencyService()
    private let apiKey = APIConfig.currencyAPIKey
    private let baseURL = "https://v6.exchangerate-api.com/v6"
    
    private var cachedRates: [String: [String: Double]] = [:]
    private var lastUpdateTime: [String: Date] = [:]
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    
    func getExchangeRate(from baseCurrency: String, to targetCurrency: String) async throws -> Double {
        // Check cache first
        if let rates = cachedRates[baseCurrency],
           let lastUpdate = lastUpdateTime[baseCurrency],
           let rate = rates[targetCurrency],
           Date().timeIntervalSince(lastUpdate) < cacheValidityDuration {
            return rate
        }
        
        // Fetch new rates
        let urlString = "\(baseURL)/\(apiKey)/latest/\(baseCurrency)"
        guard let url = URL(string: urlString) else {
            throw CurrencyError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        
        // Cache the results
        cachedRates[baseCurrency] = response.effectiveRates
        lastUpdateTime[baseCurrency] = Date()
        
        return response.effectiveRates[targetCurrency] ?? 1.0
    }
    
    func convertAmount(_ amount: Double, from baseCurrency: String, to targetCurrency: String) async throws -> Double {
        if baseCurrency == targetCurrency {
            return amount
        }
        let rate = try await getExchangeRate(from: baseCurrency, to: targetCurrency)
        return amount * rate
    }
    
    func convertCurrency(amount: Double, from: String, to: String) async throws -> Double {
        let urlString = "https://api.exchangerate-api.com/v4/latest/\(from)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(ExchangeRateResponse.self, from: data)
        
        guard let rate = response.rates?[to] else {
            throw CurrencyError.rateNotFound
        }
        
        return amount * rate
    }
}

struct ExchangeRateResponse: Codable {
    let result: String?
    let baseCode: String?
    let conversionRates: [String: Double]?
    let rates: [String: Double]?
    
    enum CodingKeys: String, CodingKey {
        case result
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
        case rates
    }
    
    var effectiveRates: [String: Double] {
        // Safely fall back to `rates` or an empty dictionary if both are nil
        return conversionRates ?? rates ?? [:]
    }
}

enum CurrencyError: Error {
    case invalidURL
    case conversionFailed
    case rateNotFound
}
