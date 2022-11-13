//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 06.11.2022.
//

import Foundation
import EssentialFeed

class FeedLoaderStub: FeedLoader {
    
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
