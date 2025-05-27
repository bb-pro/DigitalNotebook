//
//  BlurView.swift
//  DigitalNotebook
//
//  Created by Behruz Norov on 27/05/25.
//

import UIKit
import CoreImage

@IBDesignable
class FigmaBlurView: UIView {

    @IBInspectable var blurRadius: CGFloat = 4 {
        didSet {
            applyBackgroundBlur()
        }
    }

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyBackgroundBlur()
    }

    private func applyBackgroundBlur() {
        guard let superview = superview else { return }

        // Snapshot area behind this view
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
            superview.layer.render(in: context)
        }
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let inputImage = snapshot else { return }

        // Apply Gaussian blur
        guard let ciImage = CIImage(image: inputImage),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }

        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)

        let context = CIContext()
        if let outputImage = blurFilter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: ciImage.extent) {
            imageView.image = UIImage(cgImage: cgImage)
        }
    }
}
