//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 08.04.2022.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
