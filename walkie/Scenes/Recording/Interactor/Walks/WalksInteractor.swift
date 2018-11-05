//
//  WalksInteractor.swift
//  walkie
//
//  Created by Eldar Goloviznin on 07/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import CoreData

protocol WalksInteractor: class {
    func createWalk(withDate: Date) -> Walk
    func createCoordinate(atLatitude: Double, longitude: Double) -> Coordinate
    func fetchWalks(withDateComponents: DateComponents) -> [Walk]
    func delete(walk: Walk)
    func save()
}

class WalksInteractorDefault: WalksInteractor {
    
    private var context: NSManagedObjectContext {
        return CoreDataStack.persistentContainer.viewContext
    }
    
    func createWalk(withDate date: Date) -> Walk {
        let walk = Walk(context: context)
        walk.date = date
        return walk
    }
    
    func createCoordinate(atLatitude latitude: Double, longitude: Double) -> Coordinate {
        let coordinate = Coordinate(context: context)
        coordinate.latitude = latitude
        coordinate.longitude = longitude
        return coordinate
    }
    
    func fetchWalks(withDateComponents dateComponents: DateComponents) -> [Walk] {
        let walkFetchRequest: NSFetchRequest<Walk> = Walk.fetchRequest()
        
        let calendar = Calendar.current
        let startDateOfTheDay = calendar.startOfDay(for: calendar.date(from: dateComponents)!)
        let endDateOfTheDay = calendar.date(byAdding: .day, value: 1, to: startDateOfTheDay)!
        
        let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startDateOfTheDay as NSDate, endDateOfTheDay as NSDate)
        walkFetchRequest.predicate = predicate
        
        do {
            return try context.fetch(walkFetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func delete(walk: Walk) {
        context.delete(walk)
    }
    
    func save() {
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
