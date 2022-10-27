//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 04.09.2022.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in Error.connectivity}
                .flatMap{ (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        
        return task
    }
}