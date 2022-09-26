//
//  Response+StatusCode.swift
//  EssentialFeedTests
//
//  Created by Daniil Zadorozhnyy on 05.09.2022.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
