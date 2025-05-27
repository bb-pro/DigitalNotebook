//
//  FavoritesVC.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit
protocol MakeNoteDelegate: AnyObject {
    func textNoteUpdate()
    func voiceNoteUpdate()
}

class MakeNoteVC: UIViewController {

    weak var makeNoteDelegate: MakeNoteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectTextGotClicked(_ sender: UIButton) {
        if let textNoteVC = storyboard?.instantiateViewController(withIdentifier: "CreateTextNoteVC") as? CreateTextNoteVC {
            textNoteVC.delegate = self
            textNoteVC.isUpdate = false
            navigationController?.pushViewController(textNoteVC, animated: true)
        }
    }
    
    @IBAction func selectVoiceGotClicked(_ sender: UIButton) {
        if let textNoteVC = storyboard?.instantiateViewController(withIdentifier: "CreateVoiceNoteVC") as? CreateVoiceNoteVC {
            textNoteVC.delegate = self
            textNoteVC.isUpdate = false
            navigationController?.pushViewController(textNoteVC, animated: true)
        }
    }
}
extension MakeNoteVC: UpdateCollectionNotesDelegate {
    func updateData() {
        makeNoteDelegate?.textNoteUpdate()
    }
}
extension MakeNoteVC: AudioSaveDelegate {
    func audioSaved() {
        makeNoteDelegate?.voiceNoteUpdate()
    }
}
