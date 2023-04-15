//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 15.04.2023.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
    
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedImagesEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/feed")!
        
        XCTAssertEqual(received, expected)
    }
}
