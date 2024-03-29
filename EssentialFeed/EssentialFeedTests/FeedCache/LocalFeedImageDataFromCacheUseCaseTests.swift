//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 26.09.2022.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageData_requestsStoreDataFromURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = try? sut.loadImageData(from: url)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageData_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(
            sut,
            toCompleteWith: failed(),
            when: {
                let retrievalError = anyNSError()
                store.completeRetrieval(with: retrievalError)
            }
        )
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(
            sut,
            toCompleteWith: notFound(),
            when: {
                store.completeRetrieval(with: nil)
            }
        )
    }
    
    func test_loadImageData_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        expect(
            sut,
            toCompleteWith: .success(foundData),
            when: {
                store.completeRetrieval(with: foundData)
            }
        )
    }
    
    func test_save_requestsImageDataInsertionForURL() throws {
        let (sut, store) = makeSUT()
        
        let data = anyData()
        let url = anyURL()
        try sut.save(data, for: url)
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeaks(store)
        trackMemoryLeaks(sut)
        
        return (sut, store)
    }
    
    private func failed() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: Result<Data, Error>,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        action()
        
        let receivedResult = Result { try sut.loadImageData(from: anyURL()) }
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")
        }
    }
}
