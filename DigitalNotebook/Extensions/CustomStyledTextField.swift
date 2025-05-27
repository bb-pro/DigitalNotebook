//
//  File.swift
//  DigitalNotebook
//
//  Created by Developer on 22/05/25.
//

import UIKit

class CustomStyledTextField: UITextField {

    // Padding value (you can tweak it)
    private let horizontalPadding: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyCustomStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyCustomStyle()
    }

    private func applyCustomStyle() {
        layer.borderColor = UIColor(hex: "#B9A170")?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
        layer.masksToBounds = true

        self.textColor = UIColor(hex: "#B9A170")

        self.font = UIFont(name: "Nunito-Bold", size: 16)
        
        if let placeholder = self.placeholder {
            let placeholderColor = UIColor(hex: "#B9A170")?.withAlphaComponent(0.6)
            self.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: placeholderColor ?? UIColor.gray,
                    .font: UIFont(name: "Nunito-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
                ]
            )
        }
    }

    // Padding for text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: horizontalPadding, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: horizontalPadding, dy: 0)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: horizontalPadding, dy: 0)
    }
}

