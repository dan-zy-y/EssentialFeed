//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 01.05.2022.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCalls = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCalls += 1
    }
}

class FeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCalls, 0)
    }
    
    func test_save_requestTestDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCalls, 1)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(
            id: UUID(),
            description: "any",
            location: "any",
            imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return  URL(string: "http://any-url.com")!
    }
}
