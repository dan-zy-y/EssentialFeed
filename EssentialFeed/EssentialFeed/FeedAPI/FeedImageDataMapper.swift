//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 13.02.2023.
//

import Foundation

public final class FeedImageDataMapper {
    enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Self.Error.invalidData
        }
        
        return data
    }
}
