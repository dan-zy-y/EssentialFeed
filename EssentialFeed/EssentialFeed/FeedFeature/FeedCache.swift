//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 11.11.2022.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage]) throws
}
