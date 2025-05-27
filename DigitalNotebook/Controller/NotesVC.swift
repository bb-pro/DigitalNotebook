//
//  NotesVC.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit

class NotesVC: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var collectionActivityIndicator: UIActivityIndicatorView!
    
    var tabIndex: Int?
    var userNotes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionActivityIndicator?.startAnimating()
        if let email = CrownNotesAPI.shared.email {
            CrownNotesAPI.shared.getNotes(email: email) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let notes):
                        print("✅ Fetched \(notes.count) notes:")
                        self.userNotes = notes
                        let layout = PinterestLayout()
                        layout.delegate = self
                        self.collectionView.collectionViewLayout = layout
                        self.collectionView.dataSource = self
                        self.collectionView.delegate = self
                        self.collectionView.allowsSelection = true
                        self.collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                        self.collectionActivityIndicator?.stopAnimating()
                    case .failure(let error):
                        self.collectionActivityIndicator?.stopAnimating()
                        print("❌ Failed to fetch notes:", error.localizedDescription)
                        self.showAlertMessage(title: "Error", message: "Error while fetching user notes")
                    }
                }
            }
        } else {
            userNotes = convertToNotes(from: TextNoteManager.shared.fetchAllTextNotes())
            let layout = PinterestLayout()
            layout.delegate = self
            collectionView.collectionViewLayout = layout
            collectionView.dataSource = self
            collectionView.delegate = self
            self.collectionView.allowsSelection = true
            collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            collectionActivityIndicator?.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCollection()
    }
    
    @IBAction func plusGotTapped(_ sender: UIButton) {
        if let makeNoteVc = storyboard?.instantiateViewController(withIdentifier: "MakeNoteVC") as? MakeNoteVC {
            makeNoteVc.makeNoteDelegate = self
            navigationController?.pushViewController(makeNoteVc, animated: true)
        }
    }
    
    func convertToNotes(from textNotes: [TextNote]) -> [Note] {
        return textNotes.map { textNote in
            Note(
                id: textNote.noteID.uuidString,
                mail: "Unknown email",
                title: textNote.title,
                content: textNote.content
            )
        }
    }
    
    func updateCollection() {
        collectionActivityIndicator?.startAnimating()
        if let email = CrownNotesAPI.shared.email {
            CrownNotesAPI.shared.getNotes(email: email) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let notes):
                        print("✅ Fetched \(notes.count) notes:")
                        self.userNotes = notes
                        self.collectionView.reloadData()
                        self.collectionView.allowsSelection = true
                        self.collectionActivityIndicator?.stopAnimating()
                    case .failure(let error):
                        self.collectionActivityIndicator?.stopAnimating()
                        print("❌ Failed to fetch notes:", error.localizedDescription)
                        self.showAlertMessage(title: "Error", message: "Error while fetching user notes")
                    }
                }
            }
        } else {
            userNotes = convertToNotes(from: TextNoteManager.shared.fetchAllTextNotes())
            collectionActivityIndicator?.stopAnimating()
            collectionView.reloadData()
            collectionView.allowsSelection = true
        }
    }
}

// MARK: - Collection View DataSource & Delegate
extension NotesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userNotes.count + AudioManager.shared.fetchAllAudios().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCell
        cell.tabIndex = tabIndex
//        cell.index = indexPath.row
        let isNote = (indexPath.row < userNotes.count)
        cell.delegate = self
        if isNote {
            let noteData = userNotes[indexPath.row]
            cell.setupCell(tabIndex: tabIndex ?? 0, index: indexPath.row, title: noteData.title, content: noteData.content, id: noteData.id)
        } else {
            let audioData = AudioManager.shared.fetchAllAudios()[indexPath.row - userNotes.count]
            cell.setupAudioCell(tabIndex: tabIndex ?? 0, index: indexPath.row, title: audioData.title, audio: audioData.data, id: audioData.audioID.uuidString)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell tapped")
        let isNote = (indexPath.row < userNotes.count)
        if isNote {
            let noteData = userNotes[indexPath.row]
            let noteVC = storyboard?.instantiateViewController(withIdentifier: "CreateTextNoteVC") as! CreateTextNoteVC
            noteVC.delegate = self
            noteVC.noteData = noteData
            noteVC.isUpdate = true
            navigationController?.pushViewController(noteVC, animated: true)
        } else {
            let audioData = AudioManager.shared.fetchAllAudios()[indexPath.row - userNotes.count]
            let noteVC = storyboard?.instantiateViewController(withIdentifier: "CreateVoiceNoteVC") as! CreateVoiceNoteVC
            noteVC.delegate = self
            noteVC.audioData = audioData
            noteVC.isUpdate = true
            navigationController?.pushViewController(noteVC, animated: true)
        }
    }
}

// MARK: - Pinterest Layout Delegate
extension NotesVC: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        var currentNote = ""
        let characterLength = Int((UIScreen.main.bounds.width - 90) / 18)
        var currentLength = 50
        let isNote = (indexPath.row < userNotes.count)
        if isNote {
            currentNote = userNotes[indexPath.row].content
            // 21 characters per line
            if currentNote.count / characterLength <= 15 {
                currentLength += (currentNote.count / characterLength) * 20 + 20
            } else {
                currentLength += 15 * characterLength
            }
        }
        return isNote ? CGFloat(currentLength) : 185
    }
}
extension NotesVC: MakeNoteDelegate {
    func textNoteUpdate() {
        updateCollection()
        collectionView.reloadData()
    }
    
    func voiceNoteUpdate() {
        updateCollection()
    }
}

extension NotesVC: UpdateCollectionNotesDelegate {
    func updateData() {
        updateCollection()
    }
}
extension NotesVC: NoteCellActionDelegate {
    func topRightButtonTapped(index: Int, cellID: String) {
        if let tabIndex = tabIndex {
            switch tabIndex {
            case 0:
                if index < userNotes.count {
                    let noteData = userNotes[index]
                    if let email = CrownNotesAPI.shared.email {
                        CrownNotesAPI.shared.deleteNote(email: email, noteId: noteData.id) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let message):
                                    print("✅ Deleted: \(message)")
                                    self.userNotes.remove(at: index)
      //                                self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                                    self.collectionView.reloadData()
                                case .failure(let error):
                                    print("❌ Error: \(error.localizedDescription)")
                                    self.showAlertMessage(title: "Error", message: error.localizedDescription)
                                }
                            }
                        }
                    } else {
                        TextNoteManager.shared.deleteTextNote(id: UUID(uuidString: noteData.id)!)
                        self.userNotes.remove(at: index)
                        collectionView.reloadData()
                    }
                } else {
                    let audioData = AudioManager.shared.fetchAllAudios()[index - userNotes.count]
                    AudioManager.shared.deleteAudio(id: audioData.audioID)
                    collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
            case 1:
                let favorites = NoteDetailsManager.shared.fetchFavoriteNoteIDs()
                if favorites.contains(cellID) {
                    NoteDetailsManager.shared.removeFavoriteNote(noteID: cellID)
                } else {
                    NoteDetailsManager.shared.addFavoriteNote(noteID: cellID)
                }
                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
//            case 2:
//                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            default:
                break
            }
        }
    }
}
extension NotesVC: AudioSaveDelegate {
    func audioSaved() {
        updateCollection()
    }
}
