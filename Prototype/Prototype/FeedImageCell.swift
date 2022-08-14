//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Daniil Zadorozhnyy on 14.08.2022.
//

import Foundation
import UIKit

class FeedImageCell: UITableViewCell {
    @IBOutlet private (set) var locationContainer: UIView!
    @IBOutlet private (set) var locationLabel: UILabel!
    @IBOutlet private (set) var feedImageView: UIImageView!
    @IBOutlet private (set) var descriptionLabel: UILabel!
}
