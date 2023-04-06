//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 06.04.2023.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(imageId):
            return baseURL.appendingPathComponent("/image/\(imageId)/comments")
        }
    }
}
