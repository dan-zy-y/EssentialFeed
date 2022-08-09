//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by Daniil Zadorozhnyy on 07.04.2022.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
