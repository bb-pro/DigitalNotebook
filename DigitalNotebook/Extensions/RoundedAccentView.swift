//
//  RoundedAccentView.swift
//  DigitalNotebook
//
//  Created by Developer on 24/05/25.
//

import UIKit

class RoundedAccentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 10
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(named: "AccentColor")?.cgColor ?? UIColor.systemBlue.cgColor
        clipsToBounds = true
    }
}
