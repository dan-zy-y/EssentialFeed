//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 28.08.2022.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        return .init(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return .init(message: message)
    }
}
