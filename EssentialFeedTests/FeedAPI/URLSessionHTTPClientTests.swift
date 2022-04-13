//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 13.04.2022.
//

import Foundation
import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_resumesDataTaskWithURL () {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = HTTPSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = HTTPSessionSpy()
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let expectation = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                expectation.fulfill()
            default:
                XCTFail("Expected failure with error \(error), got result \(result)")
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: NSError?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeHTTPSessionDataTask(), error: NSError? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find sub for a given url")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task ?? FakeHTTPSessionDataTask()
        }
    }
    
    private class FakeHTTPSessionDataTask: HTTPSessionTask {
        func resume() {}
    }
    
    private class HTTPSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
