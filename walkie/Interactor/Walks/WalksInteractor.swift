//
//  WalksInteractor.swift
//  walkie
//
//  Created by Eldar Goloviznin on 07/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import CoreData

typealias DistanceAtDay = (startOfDay: Date, totalDistance: Double)

protocol WalksInteractor: class {
    func createWalk(withDate: Date) -> Walk
    func createCoordinate(atLatitude: Double, longitude: Double) -> Coordinate
    func save()
    func fetchWalks(atDate: Date) -> [Walk]
    func fetchDistances(atDates: ClosedRange<Date>) -> [DistanceAtDay]
}

class WalksInteractorDefault: WalksInteractor {
    
    private let coreDataStack = CoreDataStack()
    
    private var context: NSManagedObjectContext {
        return coreDataStack.persistentContainer.viewContext
    }
    
    func createWalk(withDate date: Date) -> Walk {
        let walk = NSEntityDescription.insertNewObject(forEntityName: "Walk", into: context) as! Walk
        walk.date = date as NSDate
        walk.startOfDay = Calendar.current.startOfDay(for: date) as NSDate
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
        let walkFetchRequest: NSFetchRequest<Walk> = Walk.fetchRequest()
        
        let calendar = Calendar.current
        let startDateOfTheDay = calendar.startOfDay(for: searchDate)
        let endDateOfTheDay = calendar.date(byAdding: .day, value: 1, to: startDateOfTheDay)!
        
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDateOfTheDay as NSDate, endDateOfTheDay as NSDate)
        
        walkFetchRequest.predicate = predicate
        
        do {
            return try context.fetch(walkFetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        return []
    }
    
    func fetchDistances(atDates range: ClosedRange<Date>) -> [DistanceAtDay] {
        let walkFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Walk")
        walkFetchRequest.resultType = .dictionaryResultType
        
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", range.lowerBound as NSDate, range.upperBound as NSDate)
        walkFetchRequest.predicate = predicate
        
        let totalDistanceForDayExpressionDescription = NSExpressionDescription()
        totalDistanceForDayExpressionDescription.name = "totalDistance"
        totalDistanceForDayExpressionDescription.expression = NSExpression(format: "sum:(distance)")
        totalDistanceForDayExpressionDescription.expressionResultType = .doubleAttributeType
        
        walkFetchRequest.propertiesToFetch = ["startOfDay", totalDistanceForDayExpressionDescription]
        walkFetchRequest.propertiesToGroupBy = ["startOfDay"]
        do {
            let results = try context.fetch(walkFetchRequest) as! [[String: Any]]
            return results.map({ dictionary in
                return DistanceAtDay(startOfDay: dictionary["startOfDay"] as! Date, totalDistance: dictionary["totalDistance"] as! Double)
            })
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        return []
    }
    
}
