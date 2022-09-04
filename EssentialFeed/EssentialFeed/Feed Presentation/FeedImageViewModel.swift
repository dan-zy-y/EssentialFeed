//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 04.09.2022.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
