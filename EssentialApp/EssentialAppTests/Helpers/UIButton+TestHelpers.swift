//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Daniil Zadorozhnyy on 21.08.2022.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
