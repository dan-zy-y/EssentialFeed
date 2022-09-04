//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 28.08.2022.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return .init(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return .init(message: message)
    }
}
