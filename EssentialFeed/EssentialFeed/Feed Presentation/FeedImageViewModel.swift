//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 04.09.2022.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
