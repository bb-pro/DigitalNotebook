//
//  CreateVoiceNoteVC.swift
//  DigitalNotebook
//
//  Created by Developer on 24/05/25.
//

import UIKit
import AVFoundation

protocol AudioSaveDelegate: AnyObject {
    func audioSaved()
}

class CreateVoiceNoteVC: BaseViewController {
    @IBOutlet weak var titleTextField: CustomStyledTextField!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordingProgressView: WaveformProgressView!
    @IBOutlet weak var byPassButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var resumePauseButton: UIButton!

    var isUpdate: Bool?
    var audioData: Audio?
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var totalDuration: TimeInterval = 0
    
    var timeInterval: Int = 30
    var frequency: Int = 2
    var isVisible: Bool? = true
    var recordingAudioData: Data?
    var startRecording = false
    var isRecording = false

    var recordingTimer: Timer?
    var elapsedSeconds: Int = 0
    let maxRecordingSeconds = 180
    
    weak var delegate: AudioSaveDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let isUpdate = isUpdate, let audioData = audioData {
            if isUpdate {
                timeInterval = Int(audioData.timeInterval)
                frequency = Int(audioData.frequency)
                isVisible = audioData.visibility
                titleTextField.text = audioData.title
                do {
                    audioPlayer = try AVAudioPlayer(data: audioData.data)
                    audioPlayer?.prepareToPlay()
                    totalDuration = audioPlayer?.duration ?? 0
                    recordTimeLabel.text = formatTime(totalDuration)
                    recordingProgressView.progress = 0
                } catch {
                    print("❌ Failed to load audio: \(error)")
                    recordTimeLabel.text = "00:00"
                }
                showTimeAndFrequency()
                setupVisibility()
                resumePauseButton.setImage(UIImage(resource: .pauseRecording), for: .normal)
            } else {
                
            }
        } else {
            showTimeAndFrequency()
            setupVisibility()
            updateResumePauseButton()
            resetProgress()
            resumePauseButton.setImage(UIImage(resource: .startRecording), for: .normal)
        }
    }

    @IBAction func dismissTapped(_ sender: UIButton) {
        AudioRecorderManager.shared.stopRecording { _ in }
        navigationController?.popViewController(animated: true)
    }

    @IBAction func minusTime(_ sender: UIButton) {
        if timeInterval >= 10 {
            timeInterval -= 5
            showTimeAndFrequency()
        }
    }

    @IBAction func plusTime(_ sender: UIButton) {
        if timeInterval <= 95 {
            timeInterval += 5
            showTimeAndFrequency()
        }
    }

    @IBAction func frequencyMinus(_ sender: UIButton) {
        if frequency >= 2 {
            frequency -= 1
            showTimeAndFrequency()
        }
    }

    @IBAction func frequencyPlus(_ sender: UIButton) {
        if frequency <= 19 {
            frequency += 1
            showTimeAndFrequency()
        }
    }

    @IBAction func bypassGotTapped(_ sender: UIButton) {
        isVisible = false
        setupVisibility()
    }

    @IBAction func openGotTapped(_ sender: UIButton) {
        isVisible = true
        setupVisibility()
    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {
        guard let isUpdate = isUpdate else { return }
        if isUpdate {
            guard let player = audioPlayer else { return }

            if player.isPlaying {
                player.pause()
                stopAudioTimer()
                resumePauseButton.setImage(UIImage(resource: .pauseRecording), for: .normal)
            } else {
                player.play()
                startAudioTimer()
                resumePauseButton.setImage(UIImage(resource: .continueRecording), for: .normal)
            }
        } else {
            if !startRecording {
                AudioRecorderManager.shared.requestPermission { granted in
                    if granted {
                        AudioRecorderManager.shared.startRecording { success in
                            if success {
                                self.startRecording = true
                                self.isRecording = true
                                self.updateResumePauseButton()
                                self.startTimer()
                            } else {
                                self.showAlertMessage(title: "Error", message: "Error in the beginning of recording")
                            }
                        }
                    } else {
                        self.showAlertMessage(title: "Permission Denied", message: "In order to record your voice, we need a permission.")
                    }
                }
            } else {
                if isRecording {
                    AudioRecorderManager.shared.pauseRecording()
                    stopTimer()
                    isRecording = false
                } else {
                    AudioRecorderManager.shared.resumeRecording()
                    startTimer()
                    isRecording = true
                }
                updateResumePauseButton()
            }
        }
    }

    @IBAction func doneTapped(_ sender: UIButton) {
        guard let isUpdate = isUpdate else { return }
        if isUpdate {
            guard let player = audioPlayer else { return }
            stopAudioTimer()
            player.stop()
            if let audioData = audioData,
               let titleText = self.titleTextField.text, !titleText.isEmpty {
                AudioManager.shared.updateAudio(id: audioData.audioID, newData: audioData.data, newTitle: titleText, newVisibility: isVisible!, timeInterval: timeInterval, frequency: frequency)
                delegate?.audioSaved()
                navigationController?.popViewController(animated: true)
            }
        } else {
            stopTimer()
            AudioRecorderManager.shared.stopRecording { data in
                self.recordingAudioData = data
                if let titleText = self.titleTextField.text, !titleText.isEmpty,
                     let recordingAudioData = self.recordingAudioData {
                    AudioManager.shared.createAudio(data: recordingAudioData, title: titleText, visibility: self.isVisible!, timeInterval: self.timeInterval, frequency: self.frequency)
                    self.delegate?.audioSaved()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedSeconds += 1
            self.updateProgress()
            if self.elapsedSeconds >= self.maxRecordingSeconds {
                self.recordButtonTapped(self.resumePauseButton) // force stop
            }
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func updateProgress() {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        recordTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)

        let progress = CGFloat(elapsedSeconds) / CGFloat(maxRecordingSeconds)
        recordingProgressView.progress = Float(progress)
    }

    private func resetProgress() {
        elapsedSeconds = 0
        recordTimeLabel.text = "00:00"
        recordingProgressView.progress = 0
    }

    private func updateResumePauseButton() {
        let image = isRecording ? UIImage(resource: .continueRecording) : UIImage(resource: .pauseRecording)
        resumePauseButton.setImage(image, for: .normal)
    }
}

extension CreateVoiceNoteVC {
    func showTimeAndFrequency() {
        timeIntervalLabel.text = "\(timeInterval) min"
        frequencyLabel.text = "\(frequency) times"
    }

    func setupVisibility() {
        if let isVisible = isVisible {
            openButton.backgroundColor = .accent.withAlphaComponent(isVisible ? 0.7 : 1.0)
            byPassButton.backgroundColor = .accent.withAlphaComponent(isVisible ? 1.0 : 0.7)
        } else {
            openButton.backgroundColor = .accent
            byPassButton.backgroundColor = .accent
        }
    }
}
extension CreateVoiceNoteVC {
    private func startAudioTimer() {
        stopAudioTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlaybackProgress()
        }
    }

    private func stopAudioTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    
    private func updatePlaybackProgress() {
        guard let player = audioPlayer else { return }

        let remaining = totalDuration - player.currentTime
        recordTimeLabel.text = formatTime(remaining)

        recordingProgressView.progress = Float(player.currentTime / totalDuration)

        if player.currentTime >= totalDuration {
            stopTimer()
            resumePauseButton.setImage(UIImage(resource: .pauseRecording), for: .normal)
            recordingProgressView.progress = 1.0
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
