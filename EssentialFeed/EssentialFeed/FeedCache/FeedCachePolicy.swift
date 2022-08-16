//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Zadorozhnyy, Daniil on 12.06.2022.
//

import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init() {}
    
    private static var maxCacheAgeInDays = 7
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
            
        }
        return date < maxCacheAge
    }
}
