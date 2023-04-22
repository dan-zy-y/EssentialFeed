//
//  NullStore.swift
//  EssentialApp
//
//  Created by Daniil Zadorozhnyy on 16.04.2023.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed() throws {}
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
    func retrieve() throws -> CachedFeed? {
        return nil
    }
    
    func insert(_ data: Data, for url: URL) throws {}
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        return nil
    }
}
