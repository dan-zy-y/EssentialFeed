//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Daniil Zadorozhnyy on 24.08.2022.
//

import XCTest
import EssentialFeed

class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertThatKeyAndValuesExist(in: bundle, table)
    }
}
