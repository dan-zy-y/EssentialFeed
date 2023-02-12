//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 09.04.2022.
//

import Foundation

public final class FeedItemsMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct Root: Decodable {
        private struct RemoteFeedItem: Decodable {
            var id: UUID
            var description: String?
            var location: String?
            var image: URL
            
            var item: FeedImage {
                return FeedImage(
                    id: id,
                    description: description,
                    location: location,
                    url: image
                )
            }
        }
        
        private let items: [RemoteFeedItem]
        
        var images: [FeedImage] {
            items.map {
                FeedImage(
                    id: $0.id,
                    description: $0.description,
                    location: $0.location,
                    url: $0.image
                )
            }
        }
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Self.Error.invalidData
        }
        
        return root.images
    }
}

