//
//  FeedImagesEndpoint.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 06.04.2023.
//

import Foundation

public enum FeedImagesEndpoint {
    case get(after: FeedImage? = nil)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(image):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feed"
            components.queryItems = [
                .init(name: "limit", value: "10"),
                image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) }
            ].compactMap { $0 }
            return components.url!
        }
    }
}
