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
        
        let received = FeedImagesEndpoint.get().url(baseURL: baseURL)
         
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/feed", "path")
        XCTAssertEqual(received.query, "limit=10", "query")
    }
    
    func test_feed_endpointURLAfterGivenImage() {
        let image = uniqueImage() 
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedImagesEndpoint.get(after: image).url(baseURL: baseURL)
         
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/feed", "path")
        XCTAssertEqual(received.query?.contains("limit=10"), true, "limit query")
        XCTAssertEqual(received.query?.contains("after_id=\(image.id.uuidString)"), true, "after id query")
    }
}
