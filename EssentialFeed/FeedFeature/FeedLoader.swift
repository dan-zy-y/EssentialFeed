//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by Daniil Zadorozhnyy on 07.04.2022.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
