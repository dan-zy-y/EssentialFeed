//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 29.03.2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized(for: "IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: now.adding(minutes: -5),
                username: "a username"
            ),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.adding(days: -1),
                username: "another username"
            )
        ]
        
        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 day ago",
                username: "another username"
            )
        ])
    }
    
    private func localized(for key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "ImageComments")
        if value == key {
            XCTFail("Missing localized string for key: \(key)")
        }
        return value
    }

}
