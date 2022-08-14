//
//  XCTestCase+FailableInsertionFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Zadorozhnyy, Daniil on 30.07.2022.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
     func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let insertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut)

         XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
     }

     func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert(cache: (uniqueImageFeed().local, Date()), to: sut)

         expect(sut, toRetrieve: .success(.none), file: file, line: line)
     }
 }
