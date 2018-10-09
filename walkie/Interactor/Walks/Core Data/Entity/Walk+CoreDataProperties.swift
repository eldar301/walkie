//
//  Walk+CoreDataProperties.swift
//  walkie
//
//  Created by Eldar Goloviznin on 07/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var distance: Double
    @NSManaged public var date: NSDate?
    @NSManaged public var startOfDay: NSDate?
    @NSManaged public var coordinates: NSOrderedSet?

}

// MARK: Generated accessors for coordinates
extension Walk {

    @objc(insertObject:inCoordinatesAtIndex:)
    @NSManaged public func insertIntoCoordinates(_ value: Coordinate, at idx: Int)

    @objc(removeObjectFromCoordinatesAtIndex:)
    @NSManaged public func removeFromCoordinates(at idx: Int)

    @objc(insertCoordinates:atIndexes:)
    @NSManaged public func insertIntoCoordinates(_ values: [Coordinate], at indexes: NSIndexSet)

    @objc(removeCoordinatesAtIndexes:)
    @NSManaged public func removeFromCoordinates(at indexes: NSIndexSet)

    @objc(replaceObjectInCoordinatesAtIndex:withObject:)
    @NSManaged public func replaceCoordinates(at idx: Int, with value: Coordinate)

    @objc(replaceCoordinatesAtIndexes:withCoordinates:)
    @NSManaged public func replaceCoordinates(at indexes: NSIndexSet, with values: [Coordinate])

    @objc(addCoordinatesObject:)
    @NSManaged public func addToCoordinates(_ value: Coordinate)

    @objc(removeCoordinatesObject:)
    @NSManaged public func removeFromCoordinates(_ value: Coordinate)

    @objc(addCoordinates:)
    @NSManaged public func addToCoordinates(_ values: NSOrderedSet)

    @objc(removeCoordinates:)
    @NSManaged public func removeFromCoordinates(_ values: NSOrderedSet)

}
