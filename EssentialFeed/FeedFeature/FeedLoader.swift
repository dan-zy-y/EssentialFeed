//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by Daniil Zadorozhnyy on 07.04.2022.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
