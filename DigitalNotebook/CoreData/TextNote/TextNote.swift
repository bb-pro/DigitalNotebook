//
//  TextNote.swift
//  DigitalNotebook
//
//  Created by Developer on 26/05/25.
//

import Foundation
import CoreData

@objc(TextNote)
public class TextNote: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TextNote> {
        return NSFetchRequest<TextNote>(entityName: "TextNote")
    }

    @NSManaged public var noteID: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
}
