//
//  FeedImageLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 12.11.2022.
//

import XCTest
import EssentialFeed

class FeedImageLoaderCacheDecorator: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_ , loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        
        let exp = expectation(description: "Wait for load")
        var receivedData: Data?
        _ = sut.loadImageData(from: anyURL()) { result in
            receivedData = try? result.get()
            exp.fulfill()
        }
        
        let imageData = anyData()
        loader.complete(with: .success(imageData))
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedData, imageData)
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImageLoaderCacheDecorator, FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageLoaderCacheDecorator(decoratee: loader)
        trackMemoryLeaks(loader)
        trackMemoryLeaks(sut)
        
        return (sut, loader)
    }
}
