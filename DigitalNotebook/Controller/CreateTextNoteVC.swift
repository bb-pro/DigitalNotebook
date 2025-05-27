//
//  CreateTextNoteVC.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit

protocol UpdateCollectionNotesDelegate: AnyObject {
    func updateData()
}

class CreateTextNoteVC: BaseViewController {
    @IBOutlet weak var titleTextField: CustomStyledTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var byPassButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var isUpdate: Bool?
    var noteData: Note?
    var timeInterval: Int = 30
    var frequency: Int = 2
    var isVisible: Bool? = true
    weak var delegate: UpdateCollectionNotesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isUpdate = isUpdate, let noteData = noteData {
            if isUpdate {
                titleLabel.text = "Details of note"
                titleTextField.text = noteData.title
                descriptionTextView.text = noteData.content
                if NoteDetailsManager.shared.fetchHiddenNoteIDs().contains(noteData.id) {
                    isVisible = false
                }
            }
        }
        showTimeAndFrequency()
        setupVisibility()
    }
    
    @IBAction func dismissGotClicked(_ sender: UIButton) {
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
    
    @IBAction func minusFrequency(_ sender: UIButton) {
        if frequency >= 2 {
            frequency -= 1
            showTimeAndFrequency()
        }
    }
    
    @IBAction func plusFrequency(_ sender: UIButton) {
        if frequency <= 19 {
            frequency += 1
            showTimeAndFrequency()
        }
    }
    
    @IBAction func byPassGotTapped(_ sender: UIButton) {
        isVisible = false
        setupVisibility()
    }
    
    @IBAction func openGotTapped(_ sender: UIButton) {
        isVisible = true
        setupVisibility()
    }
    
    @IBAction func doneGotTapped(_ sender: UIButton) {
        if let titleText = titleTextField.text, !titleText.isEmpty,
           let content = descriptionTextView.text, !content.isEmpty,
           let isUpdate = isUpdate {
            if isUpdate {
                if let noteData = noteData, let email = CrownNotesAPI.shared.email {
                    if !isVisible! && !NoteDetailsManager.shared.fetchHiddenNoteIDs().contains(noteData.id) {
                        NoteDetailsManager.shared.addHiddenNote(noteID: noteData.id)
                    } else if isVisible! && NoteDetailsManager.shared.fetchHiddenNoteIDs().contains(noteData.id) {
                        NoteDetailsManager.shared.removeHiddenNote(noteID: noteData.id)
                    }
                    CrownNotesAPI.shared.editNote(
                        email: email,
                        noteId: noteData.id,
                        title: titleText,
                        content: content
                    ) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let message):
                                print("✅ Edit successful: \(message)")
                                self.delegate?.updateData()
                                self.navigationController?.popViewController(animated: true)
                            case .failure(let error):
                                print("❌ Edit failed: \(error.localizedDescription)")
                                self.showAlertMessage(title: "Error", message: "Error occurred while updating the note.")
                            }
                        }
                    }
                } else {
                    if let id = noteData?.id {
                        TextNoteManager.shared.updateTextNote(id: UUID(uuidString: id)!, newTitle: titleText, newContent: content)
                        delegate?.updateData()
                        navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                if let email = CrownNotesAPI.shared.email {
                    CrownNotesAPI.shared.addNote(email: email, title: titleText, content: content) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let message):
                                print("✅ Note added successfully:", message)
                                self.delegate?.updateData()
                                self.navigationController?.popViewController(animated: true)
                                
                            case .failure(let error):
                                print("❌ Failed to add note:", error.localizedDescription)
                                self.showAlertMessage(title: "Error", message: "Error occurred while saving the note.")
                            }
                        }
                    }
                } else {
                    TextNoteManager.shared.createTextNote(title: titleText, content: content)
                    delegate?.updateData()
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
extension CreateTextNoteVC {
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
