//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 05.06.2022.
//

import Foundation

struct RemoteFeedItem: Decodable {
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
