//
//  FeedItem.swift
//  FeedItem
//
//  Created by Daniil Zadorozhnyy on 07.04.2022.
//

import Foundation

public struct FeedItem: Equatable {
    var id: UUID
    var description: String?
    var location: String?
    var url: URL
}
