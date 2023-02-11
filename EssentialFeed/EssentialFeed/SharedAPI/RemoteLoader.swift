//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 11.02.2023.
//

import Foundation

public class RemoteLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else {  return }
            switch result {
            case let .success(data, response):
                completion(Self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
