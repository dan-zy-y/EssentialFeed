//
//  FeedImagesEndpoint.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 06.04.2023.
//

import Foundation

public enum FeedImagesEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feed"
            components.queryItems = [
                .init(name: "limit", value: "10")
            ]
            return components.url!
        }
    }
}
