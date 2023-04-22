//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Daniil Zadorozhnyy on 21.08.2022.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
