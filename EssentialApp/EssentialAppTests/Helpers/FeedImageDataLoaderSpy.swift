//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 12.11.2022.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private (set) var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        return messages.map(\.url)
    }
    
    private struct Task: FeedImageDataLoaderTask {
        var callback: () -> Void
        
        func cancel() {
            callback()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task(callback: { [weak self] in self?.cancelledURLs.append(url) })
    }
    
    func complete(with result: FeedImageDataLoader.Result, at index: Int = 0) {
        messages[index].completion(result)
    }
}
