//
//  SettingsCell.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 19.11.2021.
//

import Foundation
import UIKit

struct SettingsCell {
    var cellType: CellType?
    var img: UIImage?
    var labelText: String?
}
enum CellType {
    case contactSupport
    case appearance
}
