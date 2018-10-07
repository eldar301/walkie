//
//  WalksInteractor.swift
//  walkie
//
//  Created by Eldar Goloviznin on 07/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import CoreData

protocol WalksInteractor {
    func createWalk(withDate: Date) -> Walk
    func createCoordinate(atLatitude: Double, longitude: Double) -> Coordinate
    func save()
    func fetchWalks(atDate: Date) -> [Walk]
    func fetchDistance(atDates: Range<Date>) -> [Double]
}

class WalksInteractorDefault: WalksInteractor {
    
    private let coreDataStack = CoreDataStack()
    
    private var context: NSManagedObjectContext {
        return coreDataStack.persistentContainer.viewContext
    }
    
    func createWalk(withDate date: Date) -> Walk {
        let walk = NSEntityDescription.insertNewObject(forEntityName: "Walk", into: context) as! Walk
        walk.date = date as NSDate
        return walk
    }
    
    func createCoordinate(atLatitude latitude: Double, longitude: Double) -> Coordinate {
        let coordinate = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: context) as! Coordinate
        coordinate.latitude = latitude
        coordinate.longitude = longitude
        return coordinate
    }
    
    func save() {
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchWalks(atDate searchDate: Date) -> [Walk] {
        let fetchRequest: NSFetchRequest<Walk> = Walk.fetchRequest()
        
        let calendar = Calendar.current
        let startDateOfTheDay = calendar.startOfDay(for: searchDate)
        let endDateOfTheDay = calendar.date(byAdding: .day, value: 1, to: startDateOfTheDay)!
        
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDateOfTheDay as NSDate, endDateOfTheDay as NSDate)
        
        fetchRequest.predicate = predicate
        
        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func fetchDistance(atDates: Range<Date>) -> [Double] {
        return []
    }
    
}
