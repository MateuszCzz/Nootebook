//
//  Note+CoreDataProperties.swift
//  Nootebook
//
//  Created by asd on 19/06/2023.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var color: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var happiness: Int16
    @NSManaged public var noteID: UUID?
    @NSManaged public var notebook: Notebook?

}

extension Note: Identifiable {
    public var id: UUID {
        noteID ?? UUID()
    }
}

