//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 12.11.2022.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
