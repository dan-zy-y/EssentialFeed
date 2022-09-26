//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 26.09.2022.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
