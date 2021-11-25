//
//  HistoryCell.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import Foundation
import UIKit

class HistoryTableViewCell: UITableViewCell {
    var typeLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
    }

    func configure() {
        self.backgroundColor = Asset.Colors.mainBackground.color
        self.selectionStyle = .none
        typeLabel = UILabel(frame: .zero)
        typeLabel.font = typeLabel.font.withSize(15)
        self.contentView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(24)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
