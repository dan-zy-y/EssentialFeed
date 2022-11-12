//
//  FeedImageLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 12.11.2022.
//

import XCTest
import EssentialFeed

class FeedImageLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        }
    }
}

final class FeedImageLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {

    func test_init_doesNotLoadImageData() {
        let (_ , loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromLoader() {
        let (sut, loader) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url])
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let (sut, loader) = makeSUT()
        
        let url = anyURL()
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL loading from loader")
    }
    
    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        
        let imageData = anyData()
        expect(sut, toCompleteWith: .success(imageData), when: {
            loader.complete(with: .success(imageData))
        })
    }
    
    func test_loadImageData_deliversErrorOnLoadError() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            loader.complete(with: .failure(anyNSError()))
        })
    }
    
    func test_loadImageData_cachesLoadedImageFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let url = anyURL()
        let imageData = anyData()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: .success(imageData))
        
        XCTAssertEqual(cache.messages, [.save(data: imageData, url: url)])
    }
    
    func test_loadImageData_doesNotCacheLoadedImageFeedOnLoaderFailure() {
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        loader.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    private func makeSUT(
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImageLoaderCacheDecorator, FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackMemoryLeaks(loader)
        trackMemoryLeaks(sut)
        
        return (sut, loader)
    }
    
    private class CacheSpy: FeedImageDataCache {
        private (set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(data: Data, url: URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data: data, url: url))
            completion(.success(()))
        }
    }
}
