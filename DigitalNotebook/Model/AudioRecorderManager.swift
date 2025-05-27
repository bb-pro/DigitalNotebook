//
//  AudioRecorderManager.swift
//  DigitalNotebook
//
//  Created by Developer on 25/05/25.
//

import AVFoundation

class AudioRecorderManager: NSObject {
    
    static let shared = AudioRecorderManager()
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private(set) var isRecording = false
    private(set) var isPaused = false
    private var currentURL: URL?
    
    override private init() {
        super.init()
        configureSession()
    }
    
    private func configureSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try recordingSession.setActive(true)
        } catch {
            print("❌ Failed to configure audio session:", error.localizedDescription)
        }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        recordingSession.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func startRecording(fileName: String = UUID().uuidString, completion: ((Bool) -> Void)? = nil) {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).m4a")
        currentURL = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            isPaused = false
            completion?(true)
        } catch {
            print("❌ Failed to start recording:", error.localizedDescription)
            completion?(false)
        }
    }
    
    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        isPaused = true
    }
    
    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        isPaused = false
    }
    
    func stopRecording(completion: @escaping (Data?) -> Void) {
        guard isRecording else {
            completion(nil)
            return
        }

        audioRecorder?.stop()
        isRecording = false
        isPaused = false

        // Wait a tiny moment to ensure file is finalized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let url = self.currentURL else {
                completion(nil)
                return
            }

            do {
                let audioData = try Data(contentsOf: url)
                completion(audioData)
            } catch {
                print("❌ Failed to load audio data from file:", error.localizedDescription)
                completion(nil)
            }
        }
    }

}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("⚠️ Recording finished unsuccessfully")
        }
    }
}
