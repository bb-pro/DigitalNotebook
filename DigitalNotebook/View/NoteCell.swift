//
//  NoteCell.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit
import AVFoundation

protocol NoteCellActionDelegate: AnyObject {
    func topRightButtonTapped(index: Int, cellID: String)
}

class NoteCell: UICollectionViewCell {
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var waveProgressView: WaveformProgressView!
    @IBOutlet weak var resumePauseButton: UIButton!
    @IBOutlet weak var viewToBlur: UIView!
    
    private var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
        }
    }
    private var playbackTimer: Timer?
    private var totalDuration: TimeInterval = 0
    
    var tabIndex: Int?
    var cellID: String?
    var index: Int?
    weak var delegate: NoteCellActionDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(resource: .accent).cgColor
    }
    
    func applyLowerAlpha(alpha: CGFloat = 0.6) {
        titleLabel.alpha = alpha
        noteLabel.alpha = alpha
        timerLabel.alpha = alpha
        waveProgressView.alpha = alpha
        resumePauseButton.alpha = alpha
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noteLabel.isHidden = false
        timerLabel.isHidden = false
        waveProgressView.isHidden = false
        resumePauseButton.isHidden = false
        viewToBlur.subviews.forEach {
            if $0.tag == 999 { $0.removeFromSuperview() }
        }
    }
    
    @IBAction func xGotTapped(_ sender: UIButton) {
        print("Tapped")
        if let index = index, let cellID = cellID {
            delegate?.topRightButtonTapped(index: index, cellID: cellID)
            let hiddens = NoteDetailsManager.shared.fetchHiddenNoteIDs()
            if hiddens.contains(cellID) {
                NoteDetailsManager.shared.removeHiddenNote(noteID: cellID)
            } else {
                NoteDetailsManager.shared.addHiddenNote(noteID: cellID)
            }
            
            if let tabIndex = tabIndex {
                if tabIndex == 2 {
                    let isAvailableInHidden = NoteDetailsManager.shared.fetchHiddenNoteIDs().contains(cellID)
                    xButton.setBackgroundImage(UIImage(resource: isAvailableInHidden ? .lockedKey : .unlockedKey), for: .normal)
                    if isAvailableInHidden {
                        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                            self.viewToBlur.alpha = 1.0
                        }
                    } else {
                        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                            self.viewToBlur.alpha = 0.0
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func resumePauseButtonGotClicked(_ sender: UIButton) {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
            stopTimer()
            resumePauseButton.setBackgroundImage(UIImage(resource: .resumeButton), for: .normal)
        } else {
            player.play()
            startTimer()
            resumePauseButton.setBackgroundImage(UIImage(resource: .pauseButton), for: .normal)
        }
    }
    
    func setupCell(tabIndex: Int, index: Int, title: String, content: String, id: String) {
        self.tabIndex = tabIndex
        if self.tabIndex! == 0 {
            viewToBlur.isHidden = true
            xButton.setBackgroundImage(UIImage(resource: .xButton), for: .normal)
        } else if self.tabIndex! == 1 {
            viewToBlur.isHidden = true
            let isAvailableInFavorites = NoteDetailsManager.shared.fetchFavoriteNoteIDs().contains(id)
            xButton.setBackgroundImage(UIImage(resource: isAvailableInFavorites ? .filledHeart : .emptyHeart), for: .normal)
        } else {
            let isAvailableInHidden = NoteDetailsManager.shared.fetchHiddenNoteIDs().contains(id)
            viewToBlur.alpha = isAvailableInHidden ? 1.0 : 0.0
            xButton.setBackgroundImage(UIImage(resource: isAvailableInHidden ? .lockedKey : .unlockedKey), for: .normal)
        }
        self.index = index
        self.cellID = id
        noteLabel.isHidden = false
        timerLabel.isHidden = true
        waveProgressView.isHidden = true
        resumePauseButton.isHidden = true
        titleLabel.text = title
        noteLabel.text = content
    }
    
    func setupAudioCell(tabIndex: Int, index: Int, title: String, audio: Data, id: String) {
        self.tabIndex = tabIndex
        if self.tabIndex! == 0 {
            viewToBlur.isHidden = true
            xButton.setBackgroundImage(UIImage(resource: .xButton), for: .normal)
        } else if self.tabIndex! == 1 {
            viewToBlur.isHidden = true
            let isAvailableInFavorites = NoteDetailsManager.shared.fetchFavoriteNoteIDs().contains(id)
            xButton.setBackgroundImage(UIImage(resource: isAvailableInFavorites ? .filledHeart : .emptyHeart), for: .normal)
        } else {
            let isAvailableInHidden = NoteDetailsManager.shared.fetchHiddenNoteIDs().contains(id)
//            if isAvailableInHidden {
//                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut) {
//                    self.viewToBlur.alpha = 10.0
//                }
//            } else {
//                UIView.animate(withDuration: 10.0, delay: 0, options: .curveEaseInOut) {
//                    self.viewToBlur.alpha = 0.0
//                }
//            }
            viewToBlur.alpha = isAvailableInHidden ? 1.0 : 0.0
            xButton.setBackgroundImage(UIImage(resource: isAvailableInHidden ? .lockedKey : .unlockedKey), for: .normal)
        }
        self.index = index
        self.cellID = id
        noteLabel.isHidden = true
        timerLabel.isHidden = false
        waveProgressView.isHidden = false
        resumePauseButton.isHidden = false
        titleLabel.text = title
        
        do {
            audioPlayer = try AVAudioPlayer(data: audio)
            audioPlayer?.prepareToPlay()
            totalDuration = audioPlayer?.duration ?? 0
            timerLabel.text = formatTime(totalDuration)
            resumePauseButton.setBackgroundImage(UIImage(resource: .resumeButton), for: .normal)
            waveProgressView.progress = 0
        } catch {
            print("❌ Failed to load audio: \(error)")
            timerLabel.text = "00:00"
        }
    }
    
    private func startTimer() {
        stopTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlaybackProgress()
        }
    }

    private func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }


    
    private func updatePlaybackProgress() {
        guard let player = audioPlayer else { return }

        let remaining = totalDuration - player.currentTime
        timerLabel.text = formatTime(remaining)

        waveProgressView.progress = Float(player.currentTime / totalDuration)

        if totalDuration - player.currentTime < 0.02 { // 200ms tolerance
            player.stop()
            stopTimer()
            waveProgressView.progress = 1.0
            timerLabel.text = "00:00"
            DispatchQueue.main.async {
                self.resumePauseButton.setBackgroundImage(UIImage(resource: .resumeButton), for: .normal)
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func applyGaussianBlur(to view: UIView, blurRadius: CGFloat = 10.0) {
        guard let superview = view.superview else { return }

        // Take a snapshot of the superview content behind the blur view
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: -view.frame.origin.x, y: -view.frame.origin.y)
            superview.layer.render(in: context)
        }
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let inputImage = snapshot,
              let ciImage = CIImage(image: inputImage),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }

        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)

        let context = CIContext()
        let expandedRect = ciImage.extent.insetBy(dx: -blurRadius, dy: -blurRadius)

        guard let outputImage = blurFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: expandedRect) else {
            return
        }

        // Remove any old blur layers
        view.subviews.forEach {
            if $0.tag == 999 || $0.tag == 998 { $0.removeFromSuperview() }
        }

        // Apply the blurred image
        let blurredImage = UIImage(cgImage: cgImage)
        let blurImageView = UIImageView(image: blurredImage)
        blurImageView.frame = view.bounds
        blurImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurImageView.tag = 999
        view.insertSubview(blurImageView, at: 0)

        // Optional: Add a translucent white overlay for more realistic Figma-like blur
        let overlay = UIView(frame: view.bounds)
//        overlay.backgroundColor = UIColor.accent.withAlphaComponent(0.1) // Tweak alpha if needed
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.tag = 998
        view.insertSubview(overlay, aboveSubview: blurImageView)
    }
}
extension NoteCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        waveProgressView.progress = 1.0
        timerLabel.text = "00:00"
        resumePauseButton.setBackgroundImage(UIImage(resource: .resumeButton), for: .normal)
    }
}
