//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 08.02.2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNot2xxResponse() throws {
        let samples = [199, 150, 300, 400, 500]
        let validJSON = makeItemsJSON([])
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(validJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxResponseWithInvalidJSON() throws {
        let samples = [200, 201, 250, 280, 299]
        let invalidJSON = Data(base64Encoded: "")!
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyList() throws {
        let samples = [200, 201, 250, 280, 299]
        let emptyJSON = makeItemsJSON([])
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyJSON, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONList() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username"
        )
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username"
        )
            
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { code in
            let json = makeItemsJSON([item1.json, item2.json])
            let result = try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
        }
    }
    
    // MARK: - Helpers
    private func makeItem(
        id: UUID,
        message: String,
        createdAt: (date: Date, iso8601String: String),
        username: String
    ) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        
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
