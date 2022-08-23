//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Daniil Zadorozhnyy on 23.08.2022.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
