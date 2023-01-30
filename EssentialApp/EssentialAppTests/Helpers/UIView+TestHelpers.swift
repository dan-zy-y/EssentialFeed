//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 30.01.2023.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
