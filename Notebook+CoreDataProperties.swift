//
//  Notebook+CoreDataProperties.swift
//  Nootebook
//
//  Created by asd on 19/06/2023.
//
//

import Foundation
import CoreData


extension Notebook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notebook> {
        return NSFetchRequest<Notebook>(entityName: "Notebook")
    }

    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var desc: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var image: Data?
    @NSManaged public var notebookID: UUID?
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension Notebook {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

extension Notebook: Identifiable {
    public var ißd: UUID {
        notebookID ?? UUID()
    }
}

