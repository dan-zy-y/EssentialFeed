//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 08.04.2022.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://.a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    var requestedURL: URL?
    
    private init() {}
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}