//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 27.10.2022.
//

import Foundation

func anyData() -> Data {
    return Data("any-data".utf8)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any", code: 0)
}
