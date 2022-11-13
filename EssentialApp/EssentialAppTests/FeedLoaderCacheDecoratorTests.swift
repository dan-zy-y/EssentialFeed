//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 06.11.2022.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(result: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoadFailure() {
        let sut = makeSUT(result: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(result: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheFeedOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(result: .failure(anyNSError()), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache loaded feed on failure")
    }
    
    private func makeSUT(
        result: FeedLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackMemoryLeaks(loader)
        trackMemoryLeaks(sut)
        
        return sut
    }
    
    private class CacheSpy: FeedCache {
        private (set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [EssentialFeed.FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
