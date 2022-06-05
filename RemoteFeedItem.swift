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
    
    var item: FeedItem {
        return FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: image
        )
    }
}
