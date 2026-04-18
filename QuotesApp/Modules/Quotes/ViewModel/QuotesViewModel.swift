//
//  QuotesViewModel.swift
//  QuotesApp
//
//  Created by gokul gokul on 16/04/26.
//

import Foundation

@MainActor
final class QuotesViewModel {
    
    var isLoading: ((Bool) -> Void)?
    var reloadData: (() -> Void)?
    var onError: ((AppError) -> Void)?
    
    private(set) var quotes: [Quote] = [] {
        didSet {
            reloadData?()
        }
    }
    
    private let service: APIServiceProtocol
    
    init(service: APIServiceProtocol) {
        self.service = service
    }
    
    func fetchQuotes() {
        Task {
            isLoading?(true)
            do {
                let result = try await service.fetchQuotes()
                self.quotes = result
                isLoading?(false)
            } catch {
                isLoading?(false)
                let appError = mapError(error)
                onError?(appError)
            }
        }
    }
    
    private func mapError(_ error: Error) -> AppError {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return .unknown
            case .invalidResponse:
                return .unknown
            case .statusCode:
                return .network
            case .decoding:
                return .decoding
            }
        }
        if error is URLError {
            return .network
        }
        return .unknown
    }
    
    func toggleFavorite(at index: Int) {
        quotes[index].isFavorite.toggle()
        reloadData?()
    }
    
    
}
