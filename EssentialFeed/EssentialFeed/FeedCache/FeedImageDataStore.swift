//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 26.09.2022.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
