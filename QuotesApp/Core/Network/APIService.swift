//
//  APIService.swift
//  QuotesApp
//
//  Created by gokul gokul on 16/04/26.
//

import Foundation

protocol APIServiceProtocol {
    func fetchQuotes() async throws -> [Quote]
}

final class APIService: APIServiceProtocol {
    
    private let baseURL = "https://zenquotes.io/api/quotes"
    
    func fetchQuotes() async throws -> [Quote] {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        do {
            let quotes = try JSONDecoder().decode([Quote].self, from: data)
            return quotes
        } catch {
            throw APIError.decoding
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decoding
}
