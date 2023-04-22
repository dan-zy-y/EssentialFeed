//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 11.11.2022.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
