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
            return baseURL.appendingPathComponent("/feed")
        }
    }
}
