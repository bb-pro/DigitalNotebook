//
//  AudioManager.swift
//  DigitalNotebook
//
//  Created by Developer on 24/05/25.
//

import Foundation
import CoreData
import UIKit

class AudioManager {
    static let shared = AudioManager()

    private let context: NSManagedObjectContext

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found.")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }

    // MARK: - Create
    func createAudio(audioID: UUID = UUID(), data: Data, title: String, visibility: Bool, timeInterval: Int, frequency: Int) {
        let newAudio = Audio(context: context)
        newAudio.audioID = audioID
        newAudio.data = data
        newAudio.title = title
        newAudio.visibility = visibility
        newAudio.timeInterval = Int16(timeInterval)
        newAudio.frequency = Int16(frequency)
        
        saveContext()
    }

    // MARK: - Read (All)
    func fetchAllAudios() -> [Audio] {
        let request: NSFetchRequest<Audio> = Audio.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch audios: \(error)")
            return []
        }
    }

    // MARK: - Read (By ID)
    func fetchAudio(by id: UUID) -> Audio? {
        let request: NSFetchRequest<Audio> = Audio.fetchRequest()
        request.predicate = NSPredicate(format: "audioID == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch audio by ID: \(error)")
            return nil
        }
    }

    // MARK: - Update
    func updateAudio(id: UUID, newData: Data?, newTitle: String?, newVisibility: Bool?, timeInterval: Int?, frequency: Int?) {
        guard let audio = fetchAudio(by: id) else { return }

        if let newData = newData {
            audio.data = newData
        }
        if let newTitle = newTitle {
            audio.title = newTitle
        }
        if let newVisibility = newVisibility {
            audio.visibility = newVisibility
        }
        if let timeInterval = timeInterval {
            audio.timeInterval = Int16(timeInterval)
        }
        if let frequency = frequency {
            audio.frequency = Int16(frequency)
        }
        
        saveContext()
    }

    // MARK: - Delete
    func deleteAudio(id: UUID) {
        guard let audio = fetchAudio(by: id) else { return }
        context.delete(audio)
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
