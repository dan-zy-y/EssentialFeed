//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 08.04.2022.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
