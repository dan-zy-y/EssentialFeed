//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 08.02.2023.
//

import Foundation

internal final class ImageCommentsMapper {
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
