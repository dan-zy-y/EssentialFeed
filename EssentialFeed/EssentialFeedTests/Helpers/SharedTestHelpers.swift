//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Zadorozhnyy, Daniil on 12.06.2022.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return  URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    func adding(seconds: Double) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int, calendar: Calendar = .init(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int, calendar: Calendar = .init(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
