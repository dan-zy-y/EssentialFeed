//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by Daniil Zadorozhnyy on 07.04.2022.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
