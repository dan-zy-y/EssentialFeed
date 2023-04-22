//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 12.11.2022.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
