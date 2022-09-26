//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 09.04.2022.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
