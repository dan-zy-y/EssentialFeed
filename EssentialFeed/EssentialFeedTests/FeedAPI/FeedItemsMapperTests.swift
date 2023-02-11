//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 08.04.2022.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNot200Response() throws {
        let samples = [199, 201, 300, 400, 500]
                
        let validJSON = makeItemsJSON([])
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(validJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200ResponseWithInvalidJSON() {
        let invalidJSON = Data(base64Encoded: "")!
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyList() throws {
        let emptyJSON = makeItemsJSON([])
        
        let result = try FeedItemsMapper.map(emptyJSON, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithJSONList() throws {
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https//:a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https//:a-url.com")!
        )
            
        let items = [item1.model, item2.model]
        let json = makeItemsJSON([item1.json, item2.json])
        let result = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, items)
    }
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 } 
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = [
            "items": items
        ]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
}
