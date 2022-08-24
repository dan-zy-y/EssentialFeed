//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Daniil Zadorozhnyy on 24.08.2022.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
