//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 04.09.2022.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        return FeedImageViewModel(description: image.description, location: image.location)
    }
}
