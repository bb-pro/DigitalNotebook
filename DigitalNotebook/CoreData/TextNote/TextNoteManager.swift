//
//  TextNoteManager.swift
//  DigitalNotebook
//
//  Created by Developer on 26/05/25.
//

import Foundation
import CoreData
import UIKit

class TextNoteManager {
    static let shared = TextNoteManager()

    private let context: NSManagedObjectContext

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found.")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }

    // MARK: - Create
    func createTextNote(noteID: UUID = UUID(), title: String, content: String) {
        let textNote = TextNote(context: context)
        textNote.noteID = noteID
        textNote.title = title
        textNote.content = content
        
        saveContext()
    }

    // MARK: - Read (All)
    func fetchAllTextNotes() -> [TextNote] {
        let request: NSFetchRequest<TextNote> = TextNote.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch audios: \(error)")
            return []
        }
    }

    // MARK: - Read (By ID)
    func fetchTextNote(by id: UUID) -> TextNote? {
        let request: NSFetchRequest<TextNote> = TextNote.fetchRequest()
        request.predicate = NSPredicate(format: "noteID == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch audio by ID: \(error)")
            return nil
        }
    }

    // MARK: - Update
    func updateTextNote(id: UUID, newTitle: String?, newContent: String?) {
        guard let textNote = fetchTextNote(by: id) else { return }

        if let newTitle = newTitle {
            textNote.title = newTitle
        }
        if let newContent = newContent {
            textNote.content = newContent
        }
        
        saveContext()
    }

    // MARK: - Delete
    func deleteTextNote(id: UUID) {
        guard let textNote = fetchTextNote(by: id) else { return }
        context.delete(textNote)
        saveContext()
    }

    // MARK: - Save Context
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
