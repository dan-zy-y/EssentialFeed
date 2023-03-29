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
    
    private func localized(for key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "ImageComments")
        if value == key {
            XCTFail("Missing localized string for key: \(key)")
        }
        return value
    }

}
