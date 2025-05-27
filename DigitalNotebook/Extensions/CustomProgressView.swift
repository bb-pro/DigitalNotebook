//
//  CustomProgressView.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit

class WaveformProgressView: UIProgressView {
    
    private let maskImageView = UIImageView()
    private let progressMaskLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMask()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMask()
    }
    
    private func setupMask() {
        let waveformImage = UIImage(named: "waveformImage")!
        maskImageView.image = waveformImage.withRenderingMode(.alwaysTemplate)
        maskImageView.contentMode = .scaleAspectFit
        maskImageView.frame = bounds
        maskImageView.tintColor = UIColor(red: 82/255, green: 62/255, blue: 20/255, alpha: 1.0)
        
        // Use CALayer as progress overlay
        progressMaskLayer.backgroundColor = UIColor(resource: .unselected).cgColor
        layer.addSublayer(progressMaskLayer)
        mask = maskImageView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        maskImageView.frame = bounds
        updateProgressMask()
    }
    
    override var progress: Float {
        didSet {
            updateProgressMask()
        }
    }
    
    private func updateProgressMask() {
        let width = CGFloat(progress) * bounds.width
        progressMaskLayer.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
    }
}
