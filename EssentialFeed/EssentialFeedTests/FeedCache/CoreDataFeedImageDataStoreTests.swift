//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 13.11.2022.
//

import XCTest
import EssentialFeed

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), forURL: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: notFound(), forURL: nonMatchingURL)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(sut)
        
        return sut
    }
    
    private func expect(
        _ sut: CoreDataFeedStore,
        toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult,
        forURL url: URL,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for retrieval")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(
        _ data: Data,
        for url: URL,
        into sut: CoreDataFeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for insertion")
        let image = anyData()
        sut.insert(data, for: url) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
}
