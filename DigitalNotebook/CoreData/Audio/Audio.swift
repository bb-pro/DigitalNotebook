//
//  Audio.swift
//  DigitalNotebook
//
//  Created by Developer on 24/05/25.
//

import Foundation
import CoreData

@objc(Audio)
public class Audio: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Audio> {
        return NSFetchRequest<Audio>(entityName: "Audio")
    }

    @NSManaged public var audioID: UUID
    @NSManaged public var data: Data
    @NSManaged public var title: String
    @NSManaged public var visibility: Bool
    @NSManaged public var timeInterval: Int16
    @NSManaged public var frequency: Int16
}
