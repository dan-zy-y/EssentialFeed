//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 04.09.2022.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {
    
    func test_loadImageDataFromURL_throwsInvalidDataErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_loadImageDataFromURL_throwInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()
        
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_loadImageDataFromURL_deliversNonEmptyDataOn200HTTPResponse() throws {
        let data = anyData()
        
        let result = try FeedImageDataMapper.map(data, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, data)
    }
}
