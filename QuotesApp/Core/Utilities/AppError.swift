//
//  AppError.swift
//  QuotesApp
//
//  Created by gokul gokul on 16/04/26.
//

import Foundation

enum AppError: Error {
    case network
    case decoding
    case unknown
    
    var title: String {
        switch self {
        case .network:
            return "Network Error"
        case .decoding:
            return "Data Error"
        case .unknown:
            return "Error"
        }
    }
    
    var message: String {
        switch self {
        case .network:
            return "Please check your internet connection and try again."
        case .decoding:
            return "We couldn't process the data. Please try again."
        case .unknown:
            return "Something went wrong. Please try again later."
        }
    }
}
