//
//  Quote.swift
//  QuotesApp
//
//  Created by gokul gokul on 16/04/26.
//

import Foundation

struct Quote: Decodable {
    let q: String
    let a: String
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case q
        case a
    }

    var formattedQuote: String {
        q.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var formattedAuthor: String {
        a.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
