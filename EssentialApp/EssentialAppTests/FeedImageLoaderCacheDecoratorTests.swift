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
        
        let imageData = anyData()
        expect(sut, toFinishWith: .success(imageData)) {
            loader.complete(with: .success(imageData))
        }
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
}
