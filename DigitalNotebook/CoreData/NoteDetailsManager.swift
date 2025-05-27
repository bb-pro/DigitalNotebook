//
//  HiddenFavoriteNotesManager.swift
//  DigitalNotebook
//
//  Created by Developer on 24/05/25.
//

import Foundation

class NoteDetailsManager {
    static let shared = NoteDetailsManager()
    
    private let defaults = UserDefaults.standard
    
    let hiddenNotes = "hiddenNotes"
    let favoriteNotes = "favoriteNotes"
    
    func initializeValues() {
        if defaults.value(forKey: hiddenNotes) == nil {
            defaults.setValue([] as! [String], forKey: hiddenNotes)
        }
        
        if defaults.value(forKey: favoriteNotes) == nil {
            defaults.setValue([] as! [String], forKey: favoriteNotes)
        }
    }
    
    func fetchHiddenNoteIDs() -> [String] {
        return defaults.value(forKey: hiddenNotes) as! [String]
    }
    
    func fetchFavoriteNoteIDs() -> [String] {
        return defaults.value(forKey: favoriteNotes) as! [String]
    }
    
    func addHiddenNote(noteID: String) {
        var notes = fetchHiddenNoteIDs()
        notes.append(noteID)
        defaults.setValue(notes, forKey: hiddenNotes)
    }
    
    func addFavoriteNote(noteID: String) {
        var notes = fetchFavoriteNoteIDs()
        notes.append(noteID)
        defaults.setValue(notes, forKey: favoriteNotes)
    }
    
    func removeHiddenNote(noteID: String) {
        var notes = fetchHiddenNoteIDs()
        var selectedIndex: Int?
        for (index, note) in notes.enumerated() {
            if note == noteID {
                selectedIndex = index
            }
        }
        if let selectedIndex = selectedIndex {
            notes.remove(at: selectedIndex)
        }
        defaults.setValue(notes, forKey: hiddenNotes)
    }
    
    func removeFavoriteNote(noteID: String) {
        var notes = fetchFavoriteNoteIDs()
        var selectedIndex: Int?
        for (index, note) in notes.enumerated() {
            if note == noteID {
                selectedIndex = index
            }
        }
        if let selectedIndex = selectedIndex {
            notes.remove(at: selectedIndex)
        }
        defaults.setValue(notes, forKey: favoriteNotes)
    }
}
