//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 09.04.2022.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        var items: [Item]
    }

    private struct Item: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var image: URL
        
        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try  JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
