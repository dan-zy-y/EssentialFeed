//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 09.04.2022.
//

import Foundation

struct RemoteFeedItem: Decodable {
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

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
