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
            self?.cache.save((try? result.get()) ?? Data(), for: url) { _ in }
             completion(result)
        }
    }
}

final class FeedImageLoaderCacheDecoratorTests: XCTestCase {

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
        expect(sut, toFinishWith: .success(imageData), when: {
            loader.complete(with: .success(imageData))
        })
    }
    
    func test_loadImageData_deliversErrorOnLoadError() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toFinishWith: .failure(anyNSError()), when: {
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
    
    private func expect(
        _ sut: FeedImageLoaderCacheDecorator,
        toFinishWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected \(receivedData) to equal \(expectedData)")
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected to received \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
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
