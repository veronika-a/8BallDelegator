//
//  CornerRadiusView.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit

@IBDesignable
class CornerRadiusView: UIView {
    private var gradientLayer = CAGradientLayer()

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
    }

    @IBInspectable var startColor: UIColor? {
        didSet {
            setupGradientColors()
        }
    }
    @IBInspectable var endColor: UIColor? {
        didSet {
            setupGradientColors()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }

    private func setupGradient() {
        self.layer.addSublayer(gradientLayer)
        setupGradientColors()
    }

    func setupGradientColors() {
        if let startColor = startColor, let endColor = endColor {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            layer.borderColor = borderColor?.cgColor
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupGradient()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupGradientColors()
    }
}
