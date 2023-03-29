//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 26.02.2023.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertThatKeyAndValuesExist(in: bundle, table)
    }
}
