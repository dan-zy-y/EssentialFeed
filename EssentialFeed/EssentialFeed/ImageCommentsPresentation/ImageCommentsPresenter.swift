//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 29.03.2023.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: ImageCommentsPresenter.self),
            comment: "Title for the image comments view")
    }
}
