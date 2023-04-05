//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Daniil Zadorozhnyy on 28.08.2022.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
