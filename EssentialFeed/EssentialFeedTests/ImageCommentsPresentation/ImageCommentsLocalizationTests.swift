//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 29.03.2023.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertThatKeyAndValuesExist(in: bundle, table)
    }
}
