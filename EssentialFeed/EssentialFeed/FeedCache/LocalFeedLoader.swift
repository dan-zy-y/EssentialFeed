//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 07.05.2022.
//

import Foundation

public final class LocalFeedLoader: FeedCache {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = FeedCache.Result
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        completion(
            SaveResult {
                try store.deleteCachedFeed()
                try store.insert(feed.toLocal(), timestamp: currentDate())
            }
        )
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedImage], Error>
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        completion(LoadResult {
            if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
                return cache.feed.toModels()
            }
            return []
        })
    }
}
extension LocalFeedLoader {
    
    private struct InvalidCache: Error {}
    
    public func validateCache() {
        do {
            if let cache = try store.retrieve(),
               !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
               throw InvalidCache()
            }
        } catch {
            try? store.deleteCachedFeed()
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}
